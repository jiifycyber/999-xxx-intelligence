
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
serve(async (_req) => {
  return new Response(JSON.stringify({
    service:"999XXX recommendation-api",
    status:"foundation",
    strategy:["recency","popularity","creator affinity","watch history","favorites"]
  }), {headers:{"content-type":"application/json"}});
});
