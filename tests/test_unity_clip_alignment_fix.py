"""Regression tests for Unity array-child alignment bug (21 affected clips)."""
import struct
import unittest

from tools.decode_unity_animation_clip_values import (
    aligned, array_needs_alignment, parse_clip,
)


class ClipAlignmentTests(unittest.TestCase):
    def test_child_array_flag_controls_alignment(self):
        nodes = [
            (0, "AnimationClip", -1, 0),
            (1, "m_Name", -1, 0),
            (2, "#0x31", -1, 0x4000),
            (3, "#0x31b", 4, 0),
            (3, "#0x6a", 1, 0),
            (1, "m_Legacy", 1, 0),
            (1, "m_Compressed", 1, 0),
            (1, "m_UseHighQualityCurve", 1, 0x4000),
            (1, "m_RotationCurves", -1, 0),
            (2, "#0x31", -1, 0x4000),
            (3, "#0x31b", 4, 0),
            (3, "#0x6a", 4, 0),
        ]
        # 29-byte name => 4+29=33, padded to 36; three flags, padded
        # to 40; rotation count at offset 40 and one 4-byte item at 44.
        name = b"x" * 29
        blob = (struct.pack("<i", len(name)) + name + b"\0" * 3
                + b"\0\0\1" + b"\0"
                + struct.pack("<ii", 1, 123))
        self.assertEqual(len(blob), 48)
        result = parse_clip(blob, nodes)
        self.assertEqual(result["consumed"], 48)
        self.assertEqual(result["counts"]["m_Name"], 29)
        self.assertEqual(result["counts"]["m_RotationCurves"], 1)

    def test_array_alignment_from_child_only(self):
        nodes = [(0, "root", -1, 0), (1, "Array", -1, 0x4000),
                 (2, "size", 4, 0), (2, "data", 1, 0)]
        self.assertTrue(array_needs_alignment(nodes, 0, len(nodes)))

    def test_reject_truncated(self):
        nodes = [(0, "root", -1, 0), (1, "Array", -1, 0x4000),
                 (2, "size", 4, 0), (2, "data", 1, 0)]
        with self.assertRaises(ValueError):
            parse_clip(struct.pack("<i", 5) + b"\0" * 3, nodes)

    def test_align(self):
        self.assertEqual(aligned(33), 36)


if __name__ == "__main__":
    unittest.main()
