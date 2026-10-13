const ALLOWED_CATEGORIES = new Set([
  "GLOBAL_TRAFFIC",
  "OBSERVATION",
  "ANOMALY",
  "SUSPICIOUS",
  "WAF_BLOCKED",
  "BOT_BLOCKED",
  "RATE_LIMITED",
  "DDOS_MITIGATED",
  "ENDPOINT_ALERT",
  "HIGH_CONFIDENCE_THREAT",
  "CONFIRMED_INCIDENT",
]);

function classifyCloudflareEvent(event) {
  const action = String(event.action || "").toLowerCase();
  const source = String(event.source || "").toLowerCase();

  if (action.includes("ratelimit")) {
    return {
      category: "RATE_LIMITED",
      severity: "MEDIUM",
      confirmed: false,
    };
  }

  if (
    source.includes("bot") ||
    action.includes("managed_challenge") ||
    action.includes("challenge")
  ) {
    return {
      category: "BOT_BLOCKED",
      severity: "MEDIUM",
      confirmed: false,
    };
  }

  if (
    action.includes("block") ||
    action.includes("drop")
  ) {
    return {
      category: "WAF_BLOCKED",
      severity: "HIGH",
      confirmed: false,
    };
  }

  return {
    category: "SUSPICIOUS",
    severity: "LOW",
    confirmed: false,
  };
}

function threatScore(event, classification) {
  let score = 20;

  if (classification.category === "RATE_LIMITED") score = 45;
  if (classification.category === "BOT_BLOCKED") score = 55;
  if (classification.category === "WAF_BLOCKED") score = 70;

  const action = String(event.action || "").toLowerCase();

  if (action.includes("block")) score += 5;
  if (event.ruleId) score += 5;

  return Math.min(score, 100);
}

async function queryCloudflareSecurityEvents(env) {
  const now = new Date();
  const start = new Date(now.getTime() - 10 * 60 * 1000);

  const query = `
    query Level6SecurityEvents(
      $zoneTag: string!
      $filter: FirewallEventsAdaptiveFilter_InputObject
      $limit: Int!
    ) {
      viewer {
        zones(filter: { zoneTag: $zoneTag }) {
          firewallEventsAdaptive(
            filter: $filter
            limit: $limit
            orderBy: [datetime_DESC]
          ) {
            action
            clientCountryName
            clientIP
            clientRequestHTTPHost
            clientRequestPath
            clientRequestHTTPMethodName
            datetime
            rayName
            ruleId
            source
          }
        }
      }
    }
  `;

  const response = await fetch(
    "https://api.cloudflare.com/client/v4/graphql",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${env.CLOUDFLARE_SECURITY_TOKEN}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        query,
        variables: {
          zoneTag: env.CLOUDFLARE_ZONE_ID,
          limit: 100,
          filter: {
            datetime_geq: start.toISOString(),
            datetime_leq: now.toISOString(),
          },
        },
      }),
    },
  );

  const body = await response.json();

  if (!response.ok || body.errors) {
    throw new Error(
      `Cloudflare GraphQL failure: ${JSON.stringify(body.errors || body)}`,
    );
  }

  return (
    body?.data?.viewer?.zones?.[0]?.firewallEventsAdaptive || []
  );
}

async function sha256(value) {
  const bytes = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", bytes);

  return [...new Uint8Array(digest)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function sanitizePath(path) {
  if (!path) return null;

  const withoutQuery = String(path).split("?")[0];

  return withoutQuery.length > 300
    ? withoutQuery.slice(0, 300)
    : withoutQuery;
}

async function storeEvent(env, event) {
  const classification = classifyCloudflareEvent(event);

  if (!ALLOWED_CATEGORIES.has(classification.category)) {
    throw new Error("Invalid Level 6 category");
  }

  const sourceIpHash = event.clientIP
    ? await sha256(`${env.IP_HASH_SALT}:${event.clientIP}`)
    : null;

  const payload = {
    owner_user_id: env.OWNER_USER_ID,
    occurred_at: event.datetime,
    provider: "cloudflare_security",
    category: classification.category,
    severity: classification.severity,
    confidence: classification.category === "WAF_BLOCKED" ? 90 : 75,
    threat_score: threatScore(event, classification),
    source_country: event.clientCountryName || null,
    target_country: null,
    source_ip_hash: sourceIpHash,
    source_ip_prefix: null,
    target_asset_id: event.clientRequestHTTPHost || null,
    rule_id: event.ruleId || null,
    action: event.action || null,
    sanitized_path: sanitizePath(event.clientRequestPath),
    cloudflare_ray_id: event.rayName || null,
    confirmed: false,
    confirmation_basis: null,
    metadata: {
      source: event.source || null,
      method: event.clientRequestHTTPMethodName || null,
    },
  };

  const response = await fetch(
    `${env.SUPABASE_URL}/rest/v1/security_events`,
    {
      method: "POST",
      headers: {
        apikey: env.SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,
        "Content-Type": "application/json",
        Prefer: "return=minimal",
      },
      body: JSON.stringify(payload),
    },
  );

  if (!response.ok) {
    throw new Error(
      `Supabase insert failure: ${response.status} ${await response.text()}`,
    );
  }
}

async function collect(env) {
  const events = await queryCloudflareSecurityEvents(env);

  let stored = 0;

  for (const event of events) {
    await storeEvent(env, event);
    stored++;
  }

  return {
    fetched: events.length,
    stored,
  };
}


async function storeEndpointEvent(env, body) {
  const allowedTypes = new Set([
    "NEW_LISTENING_PORT",
    "LISTENING_SERVICE_CHANGED",
    "NEW_PERSISTENCE_ITEM",
    "PERSISTENCE_ITEM_CHANGED",
    "PERSISTENCE_ITEM_REMOVED",
    "SIP_DISABLED",
    "FILEVAULT_DISABLED",
    "FAILED_LOGIN_BURST",
    "SECURITY_BASELINE_CHANGE",
    "SUSPICIOUS_PROCESS",
    "FILE_INTEGRITY_CHANGE",
    "SUSPICIOUS_OUTBOUND_CONNECTION",
    "PRIVILEGE_CHANGE",
    "SECURITY_TOOL_DISABLED",
    "ENDPOINT_OFFLINE",
    "WATCHDOG_RECOVERY",
  ]);

  const eventType = String(body.event_type || "");

  if (!allowedTypes.has(eventType)) {
    throw new Error("Unsupported endpoint event type");
  }

  const severityMap = {
    NEW_LISTENING_PORT: "MEDIUM",
    LISTENING_SERVICE_CHANGED: "MEDIUM",
    NEW_PERSISTENCE_ITEM: "MEDIUM",
    PERSISTENCE_ITEM_CHANGED: "HIGH",
    PERSISTENCE_ITEM_REMOVED: "LOW",
    SIP_DISABLED: "CRITICAL",
    FILEVAULT_DISABLED: "HIGH",
    FAILED_LOGIN_BURST: "HIGH",
    SECURITY_BASELINE_CHANGE: "MEDIUM",
    SUSPICIOUS_PROCESS: "HIGH",
    FILE_INTEGRITY_CHANGE: "HIGH",
    SUSPICIOUS_OUTBOUND_CONNECTION: "HIGH",
    PRIVILEGE_CHANGE: "HIGH",
    SECURITY_TOOL_DISABLED: "CRITICAL",
    ENDPOINT_OFFLINE: "HIGH",
    WATCHDOG_RECOVERY: "INFO",
  };

  const scoreMap = {
    NEW_LISTENING_PORT: 55,
    LISTENING_SERVICE_CHANGED: 60,
    NEW_PERSISTENCE_ITEM: 60,
    PERSISTENCE_ITEM_CHANGED: 75,
    PERSISTENCE_ITEM_REMOVED: 35,
    SIP_DISABLED: 95,
    FILEVAULT_DISABLED: 80,
    FAILED_LOGIN_BURST: 75,
    SECURITY_BASELINE_CHANGE: 50,
    SUSPICIOUS_PROCESS: 80,
    FILE_INTEGRITY_CHANGE: 75,
    SUSPICIOUS_OUTBOUND_CONNECTION: 80,
    PRIVILEGE_CHANGE: 85,
    SECURITY_TOOL_DISABLED: 95,
    ENDPOINT_OFFLINE: 70,
    WATCHDOG_RECOVERY: 0,
  };

  const payload = {
    owner_user_id: env.OWNER_USER_ID,
    occurred_at: body.occurred_at || new Date().toISOString(),
    provider: "level6_endpoint",
    category: "ENDPOINT_ALERT",
    severity: severityMap[eventType] || "MEDIUM",
    confidence: Number(body.confidence ?? 80),
    threat_score: scoreMap[eventType] || 50,
    source_country: null,
    target_country: null,
    source_ip_hash: null,
    source_ip_prefix: null,
    target_asset_id: body.hostname || "mac-endpoint",
    endpoint_id: body.endpoint_id || "macbook-primary",
    rule_id: eventType,
    rule_name: body.rule_name || eventType.replaceAll("_", " "),
    action: body.action || "OBSERVED",
    sanitized_path: null,
    cloudflare_ray_id: null,
    confirmed: false,
    confirmation_basis: null,
    metadata: {
      event_type: eventType,
      process_name: body.process_name || null,
      process_path: body.process_path || null,
      port: body.port ?? null,
      protocol: body.protocol || null,
      item_path: body.item_path || null,
      previous_value: body.previous_value || null,
      current_value: body.current_value || null,
      details: body.details || null,
    },
  };

  const response = await fetch(
    `${env.SUPABASE_URL}/rest/v1/security_events`,
    {
      method: "POST",
      headers: {
        apikey: env.SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,
        "Content-Type": "application/json",
        Prefer: "return=minimal",
      },
      body: JSON.stringify(payload),
    },
  );

  if (!response.ok) {
    throw new Error(
      `Supabase endpoint insert failure: ${response.status} ${await response.text()}`,
    );
  }
}

async function handleEndpointIngest(request, env) {
  if (request.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const auth = request.headers.get("Authorization") || "";
  const expected = `Bearer ${env.ENDPOINT_SENSOR_SECRET}`;

  if (auth !== expected) {
    return new Response("Unauthorized", { status: 401 });
  }

  let body;

  try {
    body = await request.json();
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  try {
    await storeEndpointEvent(env, body);

    return Response.json({
      ok: true,
      accepted: true,
      category: "ENDPOINT_ALERT",
      event_type: body.event_type || null,
    });
  } catch (error) {
    console.error("LEVEL6_ENDPOINT_INGEST_ERROR", error);

    return Response.json(
      {
        ok: false,
        error: String(error),
      },
      { status: 400 },
    );
  }
}



async function verifyEndpointRequest(request, env) {
  const auth = request.headers.get("Authorization") || "";
  return auth === `Bearer ${env.ENDPOINT_SENSOR_SECRET}`;
}

async function supabaseRequest(env, pathname, options = {}) {
  return fetch(
    `${env.SUPABASE_URL}/rest/v1/${pathname}`,
    {
      ...options,
      headers: {
        apikey: env.SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,
        "Content-Type": "application/json",
        ...(options.headers || {}),
      },
    },
  );
}

async function handleEndpointCommands(request, env) {
  if (request.method !== "GET") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  if (!(await verifyEndpointRequest(request, env))) {
    return new Response("Unauthorized", { status: 401 });
  }

  const url = new URL(request.url);
  const endpointId = (url.searchParams.get("endpoint_id") || "").trim();

  if (!endpointId) {
    return Response.json(
      { ok: false, error: "endpoint_id is required" },
      { status: 400 },
    );
  }

  const now = new Date().toISOString();

  const query =
    "response_commands" +
    "?select=id,security_event_id,endpoint_id,command_type,target_path,status,requested_at,expires_at" +
    `&owner_user_id=eq.${encodeURIComponent(env.OWNER_USER_ID)}` +
    `&endpoint_id=eq.${encodeURIComponent(endpointId)}` +
    "&status=eq.PENDING" +
    `&expires_at=gt.${encodeURIComponent(now)}` +
    "&order=requested_at.asc" +
    "&limit=10";

  const response = await supabaseRequest(env, query);

  if (!response.ok) {
    return Response.json(
      {
        ok: false,
        error: `Command query failed: ${response.status} ${await response.text()}`,
      },
      { status: 502 },
    );
  }

  const commands = await response.json();

  return Response.json({
    ok: true,
    endpoint_id: endpointId,
    commands,
  });
}

async function getResponseCommand(env, commandId) {
  const query =
    "response_commands" +
    "?select=*" +
    `&id=eq.${encodeURIComponent(commandId)}` +
    `&owner_user_id=eq.${encodeURIComponent(env.OWNER_USER_ID)}` +
    "&limit=1";

  const response = await supabaseRequest(env, query);

  if (!response.ok) {
    throw new Error(
      `Command lookup failed: ${response.status} ${await response.text()}`,
    );
  }

  const rows = await response.json();
  return rows[0] || null;
}

async function handleEndpointCommandAccept(request, env, commandId) {
  if (request.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  if (!(await verifyEndpointRequest(request, env))) {
    return new Response("Unauthorized", { status: 401 });
  }

  let body;

  try {
    body = await request.json();
  } catch {
    return Response.json(
      { ok: false, error: "Invalid JSON" },
      { status: 400 },
    );
  }

  const endpointId = String(body.endpoint_id || "").trim();

  if (!endpointId) {
    return Response.json(
      { ok: false, error: "endpoint_id is required" },
      { status: 400 },
    );
  }

  const command = await getResponseCommand(env, commandId);

  if (!command) {
    return Response.json(
      { ok: false, error: "Command not found" },
      { status: 404 },
    );
  }

  if (command.endpoint_id !== endpointId) {
    return Response.json(
      { ok: false, error: "Endpoint mismatch" },
      { status: 403 },
    );
  }

  if (command.status !== "PENDING") {
    return Response.json(
      { ok: false, error: `Command is ${command.status}` },
      { status: 409 },
    );
  }

  if (new Date(command.expires_at) <= new Date()) {
    await supabaseRequest(
      env,
      `response_commands?id=eq.${encodeURIComponent(commandId)}`,
      {
        method: "PATCH",
        headers: { Prefer: "return=minimal" },
        body: JSON.stringify({
          status: "EXPIRED",
          completed_at: new Date().toISOString(),
          result_message: "Command expired before endpoint acceptance",
        }),
      },
    );

    return Response.json(
      { ok: false, error: "Command expired" },
      { status: 410 },
    );
  }

  const acceptedAt = new Date().toISOString();

  const response = await supabaseRequest(
    env,
    "response_commands" +
      `?id=eq.${encodeURIComponent(commandId)}` +
      "&status=eq.PENDING",
    {
      method: "PATCH",
      headers: { Prefer: "return=representation" },
      body: JSON.stringify({
        status: "ACCEPTED",
        accepted_at: acceptedAt,
      }),
    },
  );

  if (!response.ok) {
    return Response.json(
      {
        ok: false,
        error: `Accept failed: ${response.status} ${await response.text()}`,
      },
      { status: 502 },
    );
  }

  const rows = await response.json();

  if (!rows.length) {
    return Response.json(
      { ok: false, error: "Command was already claimed" },
      { status: 409 },
    );
  }

  return Response.json({
    ok: true,
    accepted: true,
    command: rows[0],
  });
}

async function handleEndpointCommandResult(request, env, commandId) {
  if (request.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  if (!(await verifyEndpointRequest(request, env))) {
    return new Response("Unauthorized", { status: 401 });
  }

  let body;

  try {
    body = await request.json();
  } catch {
    return Response.json(
      { ok: false, error: "Invalid JSON" },
      { status: 400 },
    );
  }

  const endpointId = String(body.endpoint_id || "").trim();
  const status = String(body.status || "").toUpperCase();

  if (!endpointId) {
    return Response.json(
      { ok: false, error: "endpoint_id is required" },
      { status: 400 },
    );
  }

  if (!["SUCCEEDED", "FAILED", "REJECTED"].includes(status)) {
    return Response.json(
      {
        ok: false,
        error: "status must be SUCCEEDED, FAILED, or REJECTED",
      },
      { status: 400 },
    );
  }

  const command = await getResponseCommand(env, commandId);

  if (!command) {
    return Response.json(
      { ok: false, error: "Command not found" },
      { status: 404 },
    );
  }

  if (command.endpoint_id !== endpointId) {
    return Response.json(
      { ok: false, error: "Endpoint mismatch" },
      { status: 403 },
    );
  }

  if (!["ACCEPTED", "RUNNING"].includes(command.status)) {
    return Response.json(
      {
        ok: false,
        error: `Cannot complete command in state ${command.status}`,
      },
      { status: 409 },
    );
  }

  const evidence =
    body.evidence &&
    typeof body.evidence === "object" &&
    !Array.isArray(body.evidence)
      ? body.evidence
      : {};

  const response = await supabaseRequest(
    env,
    `response_commands?id=eq.${encodeURIComponent(commandId)}`,
    {
      method: "PATCH",
      headers: { Prefer: "return=representation" },
      body: JSON.stringify({
        status,
        completed_at: new Date().toISOString(),
        result_message: body.message || null,
        result_evidence: evidence,
      }),
    },
  );

  if (!response.ok) {
    return Response.json(
      {
        ok: false,
        error: `Result update failed: ${response.status} ${await response.text()}`,
      },
      { status: 502 },
    );
  }

  const rows = await response.json();

  return Response.json({
    ok: true,
    completed: true,
    command: rows[0] || null,
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === "/health") {
      return Response.json({
        service: "999 Cipher Level 6 Collector",
        status: "ONLINE",
        mode: "DEFENSIVE_MONITORING",
      });
    }

    if (url.pathname === "/endpoint/event") {
      return handleEndpointIngest(request, env);
    }

    if (url.pathname === "/endpoint/commands") {
      return handleEndpointCommands(request, env);
    }

    const acceptMatch = url.pathname.match(
      /^\/endpoint\/commands\/([^/]+)\/accept$/,
    );

    if (acceptMatch) {
      return handleEndpointCommandAccept(
        request,
        env,
        decodeURIComponent(acceptMatch[1]),
      );
    }

    const resultMatch = url.pathname.match(
      /^\/endpoint\/commands\/([^/]+)\/result$/,
    );

    if (resultMatch) {
      return handleEndpointCommandResult(
        request,
        env,
        decodeURIComponent(resultMatch[1]),
      );
    }

    return new Response("Not Found", { status: 404 });
  },

  async scheduled(controller, env, ctx) {
    ctx.waitUntil(
      collect(env).then((result) => { console.log("LEVEL6_COLLECTION_SUCCESS", JSON.stringify(result)); }).catch((error) => { console.error("LEVEL6_COLLECTION_ERROR", error); }),
    );
  },
};
