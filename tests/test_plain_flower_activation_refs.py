"""Source-independent tests for local Unity PPtr filtering."""
import unittest
from tools.audit_plain_flower_activation_refs import pointer_ids


class PointerTests(unittest.TestCase):
    def test_only_explicit_pptrs(self):
        tree = {"m_GameObject": {"m_FileID": 0, "m_PathID": 123},
                "m_Script": {"m_FileID": 1, "m_PathID": 88},
                "number": 123, "other": {"m_PathID": 99},
                "items": [{"link": {"m_FileID": 0, "m_PathID": 456}}]}
        self.assertEqual(set(pointer_ids(tree)), {(0, 123), (1, 88), (0, 456)})

    def test_empty(self):
        self.assertEqual(list(pointer_ids({"none": [1, "x", None]})), [])


if __name__ == "__main__":
    unittest.main()
