"""Offline tests for the bounded, rotating Gemini agent. No API key required."""
import importlib.util
import io
import json
import os
from pathlib import Path
import tempfile
import unittest
import urllib.error
from unittest import mock

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "autonomous_domain_agent.py"
spec = importlib.util.spec_from_file_location("autonomous_domain_agent", SCRIPT)
agent = importlib.util.module_from_spec(spec)
spec.loader.exec_module(agent)


class AutonomousAgentModelTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        source = self.root / "scripts" / "character.gd"
        source.parent.mkdir()
        source.write_text("x" * 10000, encoding="utf-8")
        self.source_path = "scripts/character.gd"

    @staticmethod
    def answer():
        return io.BytesIO(json.dumps({"candidates": [{
            "content": {"parts": [{"text": json.dumps({"edits": [], "summary": "No change"})}]}
        }]}).encode())

    def test_503_falls_back_to_current_model_with_small_prompt(self):
        requests = []
        def urlopen(request, timeout):
            requests.append((request, timeout))
            if len(requests) < 3:
                raise urllib.error.HTTPError(request.full_url, 503, "Unavailable", {}, None)
            return self.answer()
        env = {"GEMINI_API_KEY": "test-key", "GEMINI_MODEL": "gemini-3.8-flash",
               "GEMINI_FALLBACK_MODELS": "gemini-3.7-flash,gemini-3.6-flash"}
        with mock.patch.object(agent, "ROOT", self.root), \
             mock.patch.dict(os.environ, env), \
             mock.patch.object(agent.urllib.request, "urlopen", side_effect=urlopen), \
             mock.patch.object(agent.time, "sleep"):
            result = agent.propose("characters", [self.source_path])
        self.assertEqual(result["edits"], [])
        self.assertEqual(len(requests), 3)
        self.assertIn("gemini-3.7-flash", requests[-1][0].full_url)
        self.assertTrue(all(timeout == 35 for _, timeout in requests))
        payload = json.loads(requests[0][0].data)
        self.assertEqual(payload["generationConfig"]["thinkingConfig"]["thinkingLevel"], "low")
        self.assertLess(len(payload["contents"][0]["parts"][0]["text"]), 6500)

    def test_404_skips_bad_model_without_retry(self):
        requests = []
        def urlopen(request, timeout):
            requests.append(request.full_url)
            if len(requests) == 1:
                raise urllib.error.HTTPError(request.full_url, 404, "Not Found", {}, None)
            return self.answer()
        env = {"GEMINI_API_KEY": "test-key", "GEMINI_MODEL": "gemini-3.8-flash",
               "GEMINI_FALLBACK_MODELS": "gemini-3.5-flash-lite"}
        with mock.patch.object(agent, "ROOT", self.root), \
             mock.patch.dict(os.environ, env), \
             mock.patch.object(agent.urllib.request, "urlopen", side_effect=urlopen), \
             mock.patch.object(agent.time, "sleep"):
            agent.propose("characters", [self.source_path])
        self.assertEqual(len(requests), 2)
        self.assertIn("gemini-3.5-flash-lite", requests[1])

    def test_scheduled_outage_writes_warning_without_crashing(self):
        with tempfile.NamedTemporaryFile() as summary:
            env = {"GITHUB_EVENT_NAME": "schedule", "AGENT_DOMAIN": "characters",
                   "GITHUB_STEP_SUMMARY": summary.name}
            with mock.patch.dict(os.environ, env), \
                 mock.patch.object(agent, "candidate_paths", return_value=[self.source_path]), \
                 mock.patch.object(agent, "propose", side_effect=RuntimeError("All configured Gemini models unavailable")):
                self.assertIsNone(agent.main())
            self.assertIn("no proposal", Path(summary.name).read_text(encoding="utf-8"))

    def test_rejects_bad_shaman_match_indentation(self):
        before = (
            "  match class_id:\n"
            "   3: # Shaman\n"
            "    _launch(parent, start, target, Color.BLUE, 0.19, 0.32)\n"
            "   9: # Priest\n"
        )
        after = (
            "  match class_id:\n"
            "   3: # Shaman\n"
            "    _launch(parent, start, target, Color.CYAN, 0.21, 0.28)\n"
            "   _launch(parent, start, target, Color.BLUE, 0.19, 0.32)\n"
            "   9: # Priest\n"
        )
        with self.assertRaisesRegex(ValueError, "indentation"):
            agent.validate_gd_indentation(before, after)

    def test_accepts_same_indentation_replacement(self):
        before = "   3: # Shaman\n    _launch(parent, start, target, Color.BLUE, 0.19, 0.32)\n"
        after = "   3: # Shaman\n    _launch(parent, start, target, Color.CYAN, 0.21, 0.28)\n"
        agent.validate_gd_indentation(before, after)

    def test_coordination_triggered_outage_is_nonfatal(self):
        env = {"GITHUB_EVENT_NAME": "workflow_run", "AGENT_DOMAIN": "characters"}
        with mock.patch.dict(os.environ, env), \
             mock.patch.object(agent, "candidate_paths", return_value=[self.source_path]), \
             mock.patch.object(agent, "propose", side_effect=RuntimeError("All configured Gemini models unavailable")):
            self.assertIsNone(agent.main())

    def test_external_cron_quota_exceeded_skips_safely(self):
        with tempfile.NamedTemporaryFile() as summary:
            env = {
                "GITHUB_EVENT_NAME": "workflow_dispatch",
                "EXTERNAL_SCHEDULER": "true",
                "AGENT_DOMAIN": "characters",
                "GITHUB_STEP_SUMMARY": summary.name,
            }
            with mock.patch.dict(os.environ, env), \
                 mock.patch.object(agent, "candidate_paths", return_value=[self.source_path]), \
                 mock.patch.object(agent, "propose", side_effect=RuntimeError("Gemini quota exhausted; no more requests")):
                self.assertIsNone(agent.main())
            self.assertIn("quota exhausted", Path(summary.name).read_text(encoding="utf-8"))

    def test_429_stops_before_requesting_more_models(self):
        calls = []
        def quota_error(req, timeout):
            calls.append(req.full_url)
            raise urllib.error.HTTPError(req.full_url, 429, "Quota", {}, None)
        env = {
            "GEMINI_API_KEY": "test-key",
            "GEMINI_MODEL": "gemini-3.6-flash",
            "GEMINI_FALLBACK_MODELS": "gemini-3.5-flash-lite",
        }
        with mock.patch.object(agent, "ROOT", self.root), \
             mock.patch.dict(os.environ, env), \
             mock.patch.object(agent.urllib.request, "urlopen", side_effect=quota_error):
            with self.assertRaisesRegex(RuntimeError, "quota exhausted"):
                agent.propose("characters", [self.source_path])
        self.assertEqual(len(calls), 1)

    def test_manual_outage_still_fails_visibly(self):
        env = {"GITHUB_EVENT_NAME": "workflow_dispatch", "AGENT_DOMAIN": "characters"}
        with mock.patch.dict(os.environ, env), \
             mock.patch.object(agent, "candidate_paths", return_value=[self.source_path]), \
             mock.patch.object(agent, "propose", side_effect=RuntimeError("All configured Gemini models unavailable")):
            with self.assertRaisesRegex(RuntimeError, "unavailable"):
                agent.main()


if __name__ == "__main__":
    unittest.main()
