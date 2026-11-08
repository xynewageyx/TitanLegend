"""Offline regression tests for Gemini draft-fix safety and API failures."""
import ast
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import urllib.error

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "gemini_propose_fix.py"
SOURCE = SCRIPT.read_text(encoding="utf-8")
TREE = ast.parse(SOURCE)
FUNCTIONS = [node for node in TREE.body if isinstance(node, ast.FunctionDef) and node.name in {"safe_path", "generate"}]
# Avoid executing the workflow's top-level GitHub/Gemini operations.
NAMESPACE = {"json": json, "Path": Path, "urllib": urllib, "time": __import__("time"), "MAX_EDITS": 3}
exec(compile(ast.Module(body=FUNCTIONS, type_ignores=[]), str(SCRIPT), "exec"), NAMESPACE)


class GeminiProposalSafetyTests(unittest.TestCase):
    def test_rejects_traversal_and_disallowed_paths(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / "scripts").mkdir()
            (root / "scripts" / "valid.gd").write_text("extends Node\n")
            with patch.dict(NAMESPACE, {"ROOT": root, "ALLOWED": ("scripts/", "scenes/", "tests/", "addons/")}):
                self.assertEqual(NAMESPACE["safe_path"]("scripts/valid.gd"), root / "scripts" / "valid.gd")
                for candidate in ("scripts/../private.gd", ".github/workflows/ci.yml", "scripts/missing.gd", "scripts/evil.exe", "scripts\\valid.gd"):
                    with self.subTest(candidate=candidate), self.assertRaises(ValueError):
                        NAMESPACE["safe_path"](candidate)

    def test_rejects_symlink(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / "scripts").mkdir()
            (root / "real.gd").write_text("extends Node\n")
            (root / "scripts" / "linked.gd").symlink_to(root / "real.gd")
            with patch.dict(NAMESPACE, {"ROOT": root, "ALLOWED": ("scripts/",)}):
                with self.assertRaises(ValueError):
                    NAMESPACE["safe_path"]("scripts/linked.gd")


class GeminiEditGuardTests(unittest.TestCase):
    def test_proposals_cannot_rewrite_tests(self):
        self.assertIn('path.relative_to(ROOT).parts[0] == "tests"', SOURCE)
        self.assertIn('Gemini proposals cannot modify regression tests', SOURCE)

    def test_noop_replacements_are_rejected(self):
        self.assertIn('if old == new:', SOURCE)
        self.assertIn('No-op replacement rejected', SOURCE)

    def test_dangerous_edits_and_nul_bytes_are_rejected(self):
        self.assertIn("Potential dynamic execution or shell command rejected", SOURCE)
        self.assertIn("NUL bytes in replacement rejected", SOURCE)
        self.assertIn("re.search(dangerous, new)", SOURCE)


class GeminiApiFailureTests(unittest.TestCase):
    def call_generate(self):
        with patch.dict(NAMESPACE, {"MODEL": "test-model", "KEY": "dummy"}), \
             patch("time.sleep"):
            return NAMESPACE["generate"]("test prompt")

    def test_invalid_json_becomes_diagnostic_error(self):
        response = io.BytesIO(b"{invalid-json")
        with patch("urllib.request.urlopen", return_value=response), \
             self.assertRaisesRegex(RuntimeError, "invalid JSON"):
            self.call_generate()

    def test_malformed_api_envelopes_fail_without_edits(self):
        invalid = [
            [],
            {},
            {"candidates": []},
            {"candidates": [None]},
            {"candidates": [{"content": None}]},
            {"candidates": [{"content": {"parts": [None]}}]},
            {"candidates": [{"content": {"parts": [{"text": 123}]}}]},
            {"candidates": [{"content": {"parts": [{"text": "{}"}]}}]},
            {"candidates": [{"content": {"parts": [{"text": "[]"}]}}]},
        ]
        for payload in invalid:
            with self.subTest(payload=payload):
                response = io.BytesIO(json.dumps(payload).encode())
                with patch("urllib.request.urlopen", return_value=response), \
                     self.assertRaisesRegex(RuntimeError, "no edits attempted"):
                    self.call_generate()

    def test_quota_exhaustion_stops_immediately(self):
        error = urllib.error.HTTPError("https://example.invalid", 429, "quota", {}, None)
        with patch("urllib.request.urlopen", side_effect=error) as request:
            with self.assertRaisesRegex(RuntimeError, "Quota exhausted"):
                self.call_generate()
            self.assertEqual(request.call_count, 1)

    def test_service_unavailable_exhausts_fallbacks(self):
        error = urllib.error.HTTPError("https://example.invalid", 503, "unavailable", {}, None)
        with patch("urllib.request.urlopen", side_effect=error) as request:
            with self.assertRaisesRegex(RuntimeError, "No Gemini model available"):
                self.call_generate()
            self.assertEqual(request.call_count, 6)



class GeminiRepairWorkflowRegressionTests(unittest.TestCase):
    def test_concurrency_key_is_scoped_to_target_pr(self):
        workflow = (SCRIPT.parents[1] / ".github/workflows/gemini-draft-fix.yml").read_text()
        self.assertIn('group: gemini-draft-fix-${{ inputs.pr_number || inputs.run_id }}', workflow)
        self.assertIn("cancel-in-progress: false", workflow)

    def test_gemini_api_failure_produces_failed_job(self):
        self.assertIn("API outages and quota errors must fail CI", SOURCE)
        self.assertIn("    raise SystemExit(1)", SOURCE)

if __name__ == "__main__":
    unittest.main()
