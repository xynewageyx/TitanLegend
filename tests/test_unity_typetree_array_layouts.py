"""Defensive tests for Unity TypeTree array-layout inspection."""
import struct
import unittest
from tools.inspect_unity_typetree_array_layouts import inspect_arrays


class TypeTreeArrayLayoutTests(unittest.TestCase):
    def test_truncated(self):
        with self.assertRaisesRegex(ValueError, "Truncated"):
            inspect_arrays(b"\x00" * 12)

    def test_wrong_version(self):
        data = bytearray(40)
        struct.pack_into(">IIII", data, 0, 20, len(data), 20, 32)
        with self.assertRaisesRegex(ValueError, "v21"):
            inspect_arrays(data)

    def test_typetree_disabled(self):
        data = bytearray(48)
        struct.pack_into(">IIII", data, 0, 20, len(data), 21, 32)
        data[20:26] = b"2019\x00\x00"
        # Unity version string ends at 24; target platform at 25..28,
        # TypeTree enabled flag at 29.
        data[29] = 0
        with self.assertRaisesRegex(ValueError, "disabled"):
            inspect_arrays(data)


if __name__ == "__main__":
    unittest.main()
