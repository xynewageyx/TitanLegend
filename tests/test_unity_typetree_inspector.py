"""Synthetic regression tests for the Unity SerializedFile v21 TypeTree inspector.

These tests intentionally contain no third-party Unity asset bytes.
"""
import struct
import unittest
from unittest.mock import patch

from tools.inspect_unity_typetree import type_tree_paths


class TypeTreeInspectorTests(unittest.TestCase):
    def test_reads_nested_bindpose_field_path(self):
        # Synthetic TypeTree metadata, not extracted proprietary asset content.
        strings = b"Mesh\0m_BindPose\0Array\0size\0data\0"
        offsets = {"Mesh": 0, "m_BindPose": 5, "Array": 16,
                   "size": 22, "data": 27}
        nodes = [
            (0, "Mesh"), (1, "m_BindPose"),
            (2, "Array"), (3, "size"), (3, "data"),
        ]
        payload = bytearray(20)
        payload[16] = 0  # little endian
        payload.extend(b"2019.4.16f1\0")
        payload.extend(struct.pack("<i?i", 13, True, 1))
        payload.extend(struct.pack("<i?h", 43, False, -1))
        payload.extend(bytes(16))
        payload.extend(struct.pack("<ii", len(nodes), len(strings)))
        for i, (level, name) in enumerate(nodes):
            payload.extend(struct.pack("<hBBIIiiiQ", 1, level, 0,
                                       offsets["Mesh"], offsets[name],
                                       -1, i, 0, 0))
        payload.extend(strings)
        payload.extend(struct.pack("<i", 0))  # type dependencies
        with patch("tools.inspect_unity_typetree.inspect_serialized"):
            result = type_tree_paths(bytes(payload), 43, "BindPose")
        paths = [entry["path"] for entry in result["matching_fields"]]
        self.assertIn("Mesh/m_BindPose/Array/data", paths)
        self.assertIn("Mesh/m_BindPose/Array/size", paths)

    def test_rejects_truncated_input(self):
        with self.assertRaises(ValueError):
            type_tree_paths(b"UnityFS")

    def test_rejects_unsupported_version(self):
        data = bytearray(32)
        data[8:12] = (20).to_bytes(4, "big")
        with self.assertRaises(ValueError):
            type_tree_paths(bytes(data))

    def test_rejects_invalid_header(self):
        data = bytearray(32)
        data[8:12] = (21).to_bytes(4, "big")
        with self.assertRaises(ValueError):
            type_tree_paths(bytes(data))


if __name__ == "__main__":
    unittest.main()
