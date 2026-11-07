"""Synthetic tests for root-relative Unity bone-path CRC32 matching."""
import unittest
import zlib

from tools.check_bone_path_hashes import compare, variants


class BonePathHashTests(unittest.TestCase):
    def test_root_relative_crc32_matches(self):
        full = "PrefabRoot/Rig/Pelvis/Head"
        expected = zlib.crc32(b"Rig/Pelvis/Head") & 0xffffffff
        results = compare([(full, expected)])
        self.assertEqual(results["without_root:crc32"]["matches"], 1)
        self.assertEqual(results["without_root:crc32"]["tested"], 1)
        self.assertEqual(results["full_slash:crc32"]["matches"], 0)

    def test_backslash_paths_normalize_to_slashes(self):
        values = dict(variants("PrefabRoot\\Rig\\Head"))
        self.assertEqual(values["without_root"], "Rig/Head")

    def test_case_preservation(self):
        values = dict(variants("PrefabRoot/Rig/HEAD"))
        self.assertEqual(values["without_root"], "Rig/HEAD")
        self.assertEqual(values["without_root_lower"], "rig/head")

    def test_empty_root_relative_path_is_not_a_bone(self):
        # The root alone has no relative bone path and should be rejected.
        with self.assertRaises(ValueError):
            list(variants("PrefabRoot"))


if __name__ == "__main__":
    unittest.main()
