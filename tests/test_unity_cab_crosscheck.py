"""Synthetic tests for CAB reference-to-token crosscheck."""
import tempfile
import unittest
from pathlib import Path

from tools.crosscheck_unity_cab_references import crosscheck


class CABCrosscheckTests(unittest.TestCase):
    def test_shared_and_unseen_references(self):
        with tempfile.TemporaryDirectory() as temp:
            a = Path(temp) / "a.prefab_ab"
            b = Path(temp) / "b.prefab_ab"
            a.write_bytes(b"CAB-" + b"a" * 32)
            b.write_bytes(b"CAB-" + b"a" * 32)
            refs = {"a.prefab_ab": [
                {"fileID": 1, "path": "archive:/CAB-" + "a" * 32},
                {"fileID": 2, "path": "archive:/CAB-" + "b" * 32},
            ]}
            result = crosscheck(refs, [a, b])
            self.assertEqual(result["references_with_token_seen"], 1)
            self.assertEqual(result["references_without_token_seen"], 1)
            self.assertEqual(len(result["per_owner"]["a.prefab_ab"][0]["seen_in_files"]), 2)


if __name__ == "__main__":
    unittest.main()
