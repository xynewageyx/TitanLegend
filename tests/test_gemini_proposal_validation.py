"""Behavioral tests for Gemini proposal validation, without network or GitHub access."""
import ast
from pathlib import Path
import re
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "gemini_propose_fix.py"
tree = ast.parse(SCRIPT.read_text(encoding="utf-8"))
start = next(i for i, node in enumerate(tree.body)
             if isinstance(node, ast.Assign) and any(
                 isinstance(target, ast.Name) and target.id == "updated"
                 for target in node.targets))
end = next(i for i in range(start + 1, len(tree.body))
           if isinstance(tree.body[i], ast.For)
           and isinstance(tree.body[i].target, ast.Tuple))
VALIDATION = compile(ast.Module(body=tree.body[start:end], type_ignores=[]),
                     str(SCRIPT), "exec")


class GeminiProposalValidationTests(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.root = Path(self.folder.name)
        (self.root / "scripts").mkdir()
        (self.root / "tests").mkdir()
        self.source = self.root / "scripts" / "example.gd"
        self.source.write_text("extends Node\nvar health = 10\n", encoding="utf-8")
        self.test_file = self.root / "tests" / "test_example.py"
        self.test_file.write_text("assert True\n", encoding="utf-8")

    def validate(self, edits, allowed=None):
        allowed = allowed or [self.source]
        def safe_path(raw):
            if not isinstance(raw, str) or ".." in Path(raw).parts:
                raise ValueError("Invalid path")
            p = (self.root / raw).resolve()
            if not p.is_file() or not p.is_relative_to(self.root):
                raise ValueError("Invalid file")
            return p
        namespace = {
            "ROOT": self.root, "files": [str(p) for p in allowed],
            "edits": edits, "safe_path": safe_path, "re": re,
        }
        exec(VALIDATION, namespace)
        return namespace["updated"]

    def test_safe_edit_is_prepared_without_writing(self):
        changes = self.validate([{"path": "scripts/example.gd",
                                  "old": "health = 10", "new": "health = 11"}])
        self.assertIn("health = 11", changes[self.source])
        self.assertIn("health = 10", self.source.read_text())

    def test_dangerous_code_is_rejected_without_writing(self):
        for expression in ('eval("2+2")', 'exec("pass")',
                           'compile("x", "y", "exec")',
                           'os.system("whoami")', 'subprocess.run(["id"])'):
            with self.subTest(expression=expression):
                with self.assertRaisesRegex(SystemExit, "dynamic execution"):
                    self.validate([{"path": "scripts/example.gd",
                                    "old": "health = 10", "new": expression}])
                self.assertIn("health = 10", self.source.read_text())

    def test_nul_byte_is_rejected(self):
        with self.assertRaisesRegex(SystemExit, "NUL bytes"):
            self.validate([{"path": "scripts/example.gd",
                            "old": "health = 10", "new": "health = 11\x00"}])

    def test_multiple_edits_are_atomic_if_later_edit_is_unsafe(self):
        with self.assertRaisesRegex(SystemExit, "dynamic execution"):
            self.validate([
                {"path": "scripts/example.gd", "old": "health = 10", "new": "health = 11"},
                {"path": "scripts/example.gd", "old": "extends Node", "new": 'eval("2+2")'},
            ])
        self.assertEqual(self.source.read_text(), "extends Node\nvar health = 10\n")

    def test_test_file_edits_are_rejected(self):
        with self.assertRaisesRegex(SystemExit, "cannot modify regression tests"):
            self.validate([{"path": "tests/test_example.py",
                            "old": "assert True", "new": "assert False"}],
                          allowed=[self.test_file])

    def test_duplicate_substring_and_noop_are_rejected(self):
        for old, new, message in [
            ("Node", "Node", "No-op"),
            ("not in file", "replacement", "not uniquely"),
        ]:
            with self.subTest(old=old):
                with self.assertRaisesRegex(SystemExit, message):
                    self.validate([{"path": "scripts/example.gd",
                                    "old": old, "new": new}])


if __name__ == "__main__":
    unittest.main()
