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


class GeminiApiFailureTests(unittest.TestCase):
    def call_generate(self, side_effect):
        with patch.dict(NAMESPACE, {"MODEL": "test-model", "KEY": "dummy"}), \
             patch("urllib.request.urlopen", side_effect=side_effect), \
             patch("time.sleep"):
            return NAMESPACE["generate"]("test prompt")

    def test_invalid_json_becomes_diagnostic_error(self):
        response = io.BytesIO(b"{invalid-json")
        with self.assertRaisesRegex(RuntimeError, "invalid JSON"):
            self.call_generate(response)

    def test_quota_exhaustion_stops_immediately(self):
        error = urllib.error.HTTPError("https://example.invalid", 429, "quota", {}, None)
        with patch("urllib.request.urlopen", side_effect=error) as request:
            with self.assertRaisesRegex(RuntimeError, "Quota exhausted"):
                self.call_generate(error)
            self.assertEqual(request.call_count, 1)

    def test_service_unavailable_exhausts_fallbacks(self):
        error = urllib.error.HTTPError("https://example.invalid", 503, "unavailable", {}, None)
        with patch("urllib.request.urlopen", side_effect=error) as request:
            with self.assertRaisesRegex(RuntimeError, "No Gemini model available"):
                self.call_generate(error)
            self.assertEqual(request.call_count, 6)


if __name__ == "__main__":
    unittest.main()
