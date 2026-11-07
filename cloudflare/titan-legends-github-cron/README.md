# Cloudflare fallback scheduler for Titan Legends

Cloudflare Worker **titan-legends-github-cron** independently starts the existing
GitHub workflow `.github/workflows/autonomous-domain-agents.yml`. This is a
fallback to GitHub Actions `schedule` and to the separate coordination workflow.
The Worker runs at **08, 18, 28, 38, 48, 58 (UTC)** every hour. Cron timing is
best-effort, not guaranteed to the second. It does **not** run the game on
Cloudflare, access the Gemini key, or merge pull requests.

## One-time secret configuration (required)

1. In [GitHub fine-grained tokens](https://github.com/settings/personal-access-tokens/new),
   create a token owned by `xynewageyx`, limited to **only** repository
   `xynewageyx/TitanLegend`. Permission: **Actions: Read and write**.
   Choose an expiration and rotate the token before it expires.
2. In Cloudflare dashboard go to Workers & Pages > **titan-legends-github-cron**
   > Settings > Variables and Secrets. Add a **Secret** named exactly
   `TITAN_GITHUB_ACTIONS_TOKEN`. Enter the token **there**, never into GitHub
   source, a chat message, or a plain-text variable.
3. Check Worker Logs for "GitHub workflow dispatched (HTTP 204)" and GitHub
   Actions for a new `workflow_dispatch` run. If the token is absent,
   the Worker logs a warning and safely performs no dispatch.

The Worker itself has **no HTTP trigger endpoint**. All requests receive HTTP 404.
GitHub checks the `external_scheduler=true` input to apply the same ten-minute
deduplication logic to external dispatches; manually started jobs retain their
usual behavior. Its original `schedule` and coordination backup remain intact.

## Code / deployment

Worker source: `cloudflare/titan-legends-github-cron/worker.mjs`.
Unit tests: `node --test cloudflare/titan-legends-github-cron/worker.test.mjs`.

Deployment (using Cloudflare API or `cf`) requires a module Worker with an
exported `scheduled()` handler and exactly one Cron Trigger:
`8,18,28,38,48,58 * * * *`. Keep the secret across redeployments.
When GitHub is down or the token expires, the Worker reports an error rather
than claiming an agent ran. GitHub Actions may still queue or drop jobs, so
monitor successful agent-generated draft PRs separately.
