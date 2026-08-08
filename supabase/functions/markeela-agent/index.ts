
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const JSON_HEADERS = {"content-type":"application/json"};

function systemPrompt(mode:string) {
  const base = `
You are Markeela, the AI agent for the 999XXX platform.
Be concise, professional, and useful.
Never claim an action succeeded unless a tool/backend response confirms it.
Never approve identity/age verification, performer consent, rights, publication,
takedowns, payouts, or privileged role changes. Those require authorized human workflows.
You may explain requirements, summarize records, recommend next steps, and propose actions.
`;
  if (mode === "creator") return base + `
Creator mode: help with onboarding, verification checklist, rights/consent documentation,
submission readiness, and platform navigation.`;
  if (mode === "admin") return base + `
Admin mode: summarize queues, reports, rights status, moderation status, analytics, and
recommend review priorities. Do not make final compliance or moderation approvals.`;
  if (mode === "discovery") return base + `
Discovery mode: help the user search, filter, understand catalog metadata, and refine
recommendations using only approved catalog records.`;
  return base + `
Assistant mode: answer platform questions and route users to the correct 999XXX feature.`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {headers:{
      ...JSON_HEADERS,
      "access-control-allow-origin":"*",
      "access-control-allow-headers":"authorization, x-client-info, apikey, content-type",
    }});
  }

  try {
    const body = await req.json();
    const message = String(body.message ?? "");
    const mode = String(body.mode ?? "assistant");
    const context = body.context ?? {};

    const gateway = Deno.env.get("NINE99_INTELLIGENCE_GATEWAY_URL");
    const gatewayKey = Deno.env.get("NINE99_INTELLIGENCE_GATEWAY_KEY");

    if (!gateway || !gatewayKey) {
      return new Response(JSON.stringify({
        text:"Markeela is installed, but the 999 Intelligence gateway is not configured yet.",
        mode,
        model:"not-configured",
        suggested_actions:["Open System Status","Configure AI gateway"],
      }), {status:200,headers:JSON_HEADERS});
    }

    const r = await fetch(gateway, {
      method:"POST",
      headers:{
        "content-type":"application/json",
        "authorization":`Bearer ${gatewayKey}`,
      },
      body:JSON.stringify({
        agent:"markeela",
        task:"chat",
        mode,
        input:message,
        context,
        system:systemPrompt(mode),
      }),
    });

    const data = await r.json();
    const text = data.text ?? data.output ?? data.message ?? JSON.stringify(data);

    return new Response(JSON.stringify({
      text,
      mode,
      model:data.model ?? data.route ?? "999-intelligence",
      suggested_actions:data.suggested_actions ?? [],
      tool_results:data.tool_results ?? [],
    }), {status:r.ok?200:r.status,headers:JSON_HEADERS});
  } catch (e) {
    return new Response(JSON.stringify({
      text:`Markeela backend error: ${e}`,
      mode:"assistant",
      model:"error",
    }), {status:500,headers:JSON_HEADERS});
  }
});
