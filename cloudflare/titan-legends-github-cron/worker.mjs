// Titan Legends: independent Cloudflare Cron -> GitHub Actions dispatcher.
// Never expose the credential through source code, HTTP handlers, or logs.
// Bind TITAN_GITHUB_ACTIONS_TOKEN as a Cloudflare Worker secret.
const ENDPOINT = "https://api.github.com/repos/xynewageyx/TitanLegend/actions/workflows/autonomous-domain-agents.yml/dispatches";
const CRON = "8,18,28,38,48,58 * * * *";

export async function dispatchGitHubWorkflow(token, request = fetch) {
  if (typeof token !== "string" || !token.trim()) {
    console.warn("Titan Legends: missing TITAN_GITHUB_ACTIONS_TOKEN; dispatch skipped");
    return false;
  }
  const response = await request(ENDPOINT, {
    method: "POST",
    headers: {
      "Accept": "application/vnd.github+json",
      "Authorization": `Bearer ${token}`,
      "X-GitHub-Api-Version": "2022-11-28",
      "User-Agent": "titan-legends-cloudflare-cron",
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      ref: "main",
      inputs: { domain: "rotate", external_scheduler: "true" }
    })
  });
  if (!response.ok) {
    // Never log response bodies or the token; GitHub may include sensitive context.
    throw new Error(`GitHub workflow dispatch failed: HTTP ${response.status}`);
  }
  console.log("Titan Legends: GitHub workflow dispatched (HTTP " + response.status + ")");
  return true;
}

export default {
  async scheduled(controller, env) {
    if (controller.cron !== CRON) {
      console.warn("Titan Legends: unrecognized Cron Trigger; skipping");
      return;
    }
    await dispatchGitHubWorkflow(env.TITAN_GITHUB_ACTIONS_TOKEN);
  },
  async fetch() {
    // Deliberately no publicly callable dispatch endpoint.
    return new Response("Not found", { status: 404 });
  }
};
