
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
serve(async (_req) => {
  return new Response(JSON.stringify({
    service:"999XXX catalog-api",
    status:"ok",
    capabilities:["catalog","search","creator profiles","favorites","history"]
  }), {headers:{"content-type":"application/json"}});
});
