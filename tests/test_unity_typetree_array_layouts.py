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
        # Metadata includes the version string, target platform and TypeTree flag.
        struct.pack_into(">IIII", data, 0, 32, len(data), 21, 32)
        data[20:26] = b"2019\x00\x00"
        # Unity version string ends at 24; target platform at 25..28,
        # TypeTree enabled flag at 29.
        data[29] = 0
        with self.assertRaisesRegex(ValueError, "disabled"):
            inspect_arrays(data)

    def test_synthetic_clip_array_schema(self):
        strings = b"AnimationClip\0curves\0Array\0size\0data\0"
        offsets = {name: strings.index(name.encode() + b"\0")
                   for name in ("AnimationClip", "curves", "Array", "size", "data")}
        spec = [("AnimationClip", 0, -1), ("curves", 1, -1),
                ("Array", 2, -1), ("size", 3, 4), ("data", 3, 4)]
        nodes = b"".join(
            struct.pack("<HBBIIiiiQ", 1, level, 0, 0, offsets[name], size,
                        index, 0, 0)
            for index, (name, level, size) in enumerate(spec)
        )
        payload = (b"2019.4.16f1c1\0" + struct.pack("<i?i", 13, True, 1)
                   + struct.pack("<i?h", 74, False, -1)
                   + b"\0" * 16 + struct.pack("<ii", len(spec), len(strings))
                   + nodes + strings + struct.pack("<i", 0))
        blob = bytearray(20 + len(payload))
        struct.pack_into(">IIII", blob, 0, len(payload) + 20, len(blob), 21, len(blob))
        blob[16] = 0
        blob[20:] = payload
        result = inspect_arrays(bytes(blob))
        self.assertEqual(len(result["clip_schemas"]), 1)
        arrays = result["clip_schemas"][0]["arrays"]
        self.assertEqual(len(arrays), 1)
        self.assertEqual(arrays[0]["parent"]["name"], "curves")
        self.assertEqual(arrays[0]["element"]["name"], "data")


if __name__ == "__main__":
    unittest.main()
