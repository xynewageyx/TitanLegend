"""Test complete bounded pagination of GitHub PRs and audit comments."""
import ast
from pathlib import Path
import unittest

SOURCE = (Path(__file__).resolve().parents[1] / "tools" / "gemini_pr_monitor.py").read_text()
tree = ast.parse(SOURCE)
node = next(node for node in tree.body if isinstance(node, ast.FunctionDef)
            and node.name == "gh_pages")


class PaginationTests(unittest.TestCase):
    def make_reader(self, batches):
        calls = []
        def gh(endpoint):
            calls.append(endpoint)
            return batches[len(calls) - 1]
        namespace = {"gh": gh, "RuntimeError": RuntimeError, "range": range,
                     "len": len, "isinstance": isinstance, "list": list, "str": str}
        exec(compile(ast.Module(body=[node], type_ignores=[]), "<pagination>", "exec"), namespace)
        return namespace["gh_pages"], calls

    def test_reads_second_page(self):
        reader, calls = self.make_reader([[{"id": i} for i in range(100)], [{"id": 100}]])
        self.assertEqual(len(reader("repos/owner/game/pulls?state=open")), 101)
        self.assertIn("page=2", calls[1])
        self.assertIn("&per_page=100", calls[0])

    def test_does_not_request_extra_page(self):
        reader, calls = self.make_reader([[{"id": 1}]])
        self.assertEqual(len(reader("repos/owner/game/issues/2/comments")), 1)
        self.assertEqual(len(calls), 1)

    def test_fails_closed_when_page_limit_reached(self):
        reader, _ = self.make_reader([[{"id": i} for i in range(100)]])
        with self.assertRaisesRegex(RuntimeError, "pagination limit"):
            reader("repos/owner/game/pulls", max_pages=1)


if __name__ == "__main__":
    unittest.main()
