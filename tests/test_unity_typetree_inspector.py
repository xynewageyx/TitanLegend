"""Synthetic regression tests for the Unity SerializedFile v21 TypeTree inspector.

These tests intentionally contain no third-party Unity asset bytes.
"""
import unittest

from tools.inspect_unity_typetree import type_tree_paths


class TypeTreeInspectorTests(unittest.TestCase):
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
