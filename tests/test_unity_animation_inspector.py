"""Offline tests for tools/inspect_unity_animation.py; no proprietary bundles needed."""
import importlib.util
import json
import sys
import tempfile
import types
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "inspect_unity_animation.py"
spec = importlib.util.spec_from_file_location("inspect_unity_animation", SCRIPT)
inspector = importlib.util.module_from_spec(spec)
spec.loader.exec_module(inspector)

class FakeObject:
    def __init__(self, name, data, path_id=1):
        self.type = types.SimpleNamespace(name=name)
        self.path_id = path_id
        self.data = data
    def read_typetree(self):
        return self.data

class InspectorTests(unittest.TestCase):
    def test_clip_and_override_metadata(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            (root / "idle.anim_ab").write_bytes(b"fixture")
            (root / "controller.overridecontroller_ab").write_bytes(b"fixture")
            (root / "ignored.txt").write_text("ignored")
            clip = FakeObject("AnimationClip", {
                "m_Name": "idle", "m_SampleRate": 30, "m_Legacy": False,
                "m_MuscleClip": {"m_StartTime": 0.0, "m_StopTime": 1.25},
                "m_PositionCurves": [{"path": "Root/Hips", "curve": {"m_Curve": [{}, {}]}}, {"path": "Root/Arm", "curve": {"m_Curve": [{}]}}], "m_RotationCurves": [{"path": "Root/Hips", "curve": {"m_Curve": [{}, {}, {}]}}]
            })
            override = FakeObject("AnimatorOverrideController", {
                "m_Name": "controller", "m_Clips": [{}, {}]
            })
            def load(path):
                return types.SimpleNamespace(objects=[clip if Path(path).name == "idle.anim_ab" else override])
            original = sys.modules.get("UnityPy")
            sys.modules["UnityPy"] = types.SimpleNamespace(load=load)
            try:
                rows = inspector.inspect(root)
            finally:
                if original is None:
                    del sys.modules["UnityPy"]
                else:
                    sys.modules["UnityPy"] = original
            self.assertEqual(len(rows), 2)
            by_name = {r["file"]: r["objects"][0] for r in rows}
            self.assertEqual(by_name["idle.anim_ab"]["curve_count"], 3)
            self.assertEqual(by_name["idle.anim_ab"]["curve_paths"], ["Root/Arm", "Root/Hips"])
            self.assertEqual(by_name["idle.anim_ab"]["curve_keyframe_counts"]["m_PositionCurves"], 3)
            self.assertEqual(by_name["idle.anim_ab"]["curve_keyframe_counts"]["m_RotationCurves"], 3)
            self.assertEqual(by_name["idle.anim_ab"]["stop_time"], 1.25)
            self.assertEqual(by_name["idle.anim_ab"]["duration_seconds"], 1.25)
            self.assertEqual(by_name["idle.anim_ab"]["animated_path_count"], 2)
            self.assertEqual(by_name["controller.overridecontroller_ab"]["clip_override_count"], 2)
            json.dumps(rows)

    def test_corrupt_bundle_does_not_stop_scan(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            (root / "bad.anim_ab").write_bytes(b"bad")
            (root / "good.anim_ab").write_bytes(b"good")
            def load(path):
                if Path(path).name == "bad.anim_ab":
                    raise ValueError("invalid UnityFS")
                return types.SimpleNamespace(objects=[])
            original = sys.modules.get("UnityPy")
            sys.modules["UnityPy"] = types.SimpleNamespace(load=load)
            try:
                rows = inspector.inspect(root)
            finally:
                if original is None:
                    del sys.modules["UnityPy"]
                else:
                    sys.modules["UnityPy"] = original
            self.assertEqual(len(rows), 2)
            self.assertIn("invalid UnityFS", rows[0]["error"])
            self.assertIsNone(rows[1]["error"])

if __name__ == "__main__":
    unittest.main()
