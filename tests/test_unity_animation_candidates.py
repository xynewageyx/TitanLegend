"""Tests for conservative, filename-only Unity animation classification."""
import unittest
from tools.classify_unity_animation_candidates import classify


def row(name):
    return {"file": name + ".anim_ab", "clip_name": name,
            "legacy": 0, "object_bytes": 2048}


class AnimationCandidateTests(unittest.TestCase):
    def test_idle_and_run(self):
        report = classify([row("male@n_idle_common"), row("man@f_run")])
        self.assertEqual(report["groups"], {"idle": 1, "locomotion": 1})
        self.assertTrue(all(not x["rig_verified"] for x in report["candidates"]))

    def test_ambiguous_and_unknown(self):
        report = classify([row("fishing_idle"), row("mystery")])
        self.assertEqual(report["groups"], {"ambiguous": 1, "other": 1})

    def test_empty(self):
        self.assertEqual(classify([])["clips"], 0)


if __name__ == "__main__":
    unittest.main()
