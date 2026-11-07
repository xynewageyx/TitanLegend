import assert from "node:assert/strict";
import test from "node:test";
import worker, {dispatchGitHubWorkflow} from "./worker.mjs";

test("missing token skips network dispatch", async () => {
  let called = false;
  assert.equal(await dispatchGitHubWorkflow("", () => { called = true; }), false);
  assert.equal(called, false);
});

test("valid token dispatches main with duplicate-check input", async () => {
  let url, options;
  const fetcher = async (u, o) => {
    url = u; options = o;
    return {ok: true, status: 204};
  };
  assert.equal(await dispatchGitHubWorkflow("testing-only", fetcher), true);
  assert.equal(url, "https://api.github.com/repos/xynewageyx/TitanLegend/actions/workflows/autonomous-domain-agents.yml/dispatches");
  assert.equal(options.method, "POST");
  assert.equal(options.headers.Authorization, "Bearer testing-only");
  assert.deepEqual(JSON.parse(options.body), {
    ref: "main",
    inputs: {domain: "rotate", external_scheduler: "true"}
  });
});

test("GitHub HTTP errors fail the scheduled run", async () => {
  await assert.rejects(dispatchGitHubWorkflow("testing-only", async () => ({
    ok: false, status: 403
  })), /HTTP 403/);
});

test("worker has no public trigger endpoint", async () => {
  const r = await worker.fetch();
  assert.equal(r.status, 404);
});
