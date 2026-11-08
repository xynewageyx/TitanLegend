import struct
import unittest
from tools.unity_typetree_bounds import align4_checked, checked_array_span


class BoundsTests(unittest.TestCase):
    def test_valid_array(self):
        blob = struct.pack("<i3h", 3, 1, 2, 3)
        self.assertEqual(checked_array_span(blob, 0, 2), (3, 4, 10))

    def test_negative_count(self):
        with self.assertRaisesRegex(ValueError, "Invalid array"):
            checked_array_span(struct.pack("<i", -1), 0, 4)

    def test_truncated_payload(self):
        with self.assertRaisesRegex(ValueError, "exceeds"):
            checked_array_span(struct.pack("<i", 2) + b"\0" * 4, 0, 4)

    def test_missing_count(self):
        with self.assertRaisesRegex(ValueError, "outside"):
            checked_array_span(b"\0\0", 0, 4)

    def test_alignment(self):
        self.assertEqual(align4_checked(5, 8), 8)
        with self.assertRaisesRegex(ValueError, "exceeds"):
            align4_checked(5, 7)


if __name__ == "__main__":
    unittest.main()
