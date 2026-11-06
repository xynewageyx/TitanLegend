import importlib.util
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

SCRIPT = Path(__file__).with_name("inspect_unity_bundles.py")
spec = importlib.util.spec_from_file_location("inspect_unity_bundles", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

def obj(kind, data=None):
    return SimpleNamespace(type=SimpleNamespace(name=kind), read_typetree=lambda: data or {})

class AnalyzeTests(unittest.TestCase):
    def test_inventory_counts_and_clip_durations(self):
        fake_env = SimpleNamespace(objects=[
            obj("Mesh", {"m_Name": "CreatureMesh", "m_VertexData": {"m_VertexCount": 248}}),
            obj("SkinnedMeshRenderer", {"m_Bones": [1, 2, 3, 4]}),
            obj("AnimationClip", {"m_Name": "Attack", "m_StartTime": 0.25, "m_StopTime": 1.75}),
            obj("Animator"), obj("Transform"), obj("Material"),
        ])
        fake_unitypy = SimpleNamespace(load=lambda _: fake_env)
        with patch.dict("sys.modules", {"UnityPy": fake_unitypy}):
            row = module.inspect(Path("sample.prefab_ab"))
        self.assertEqual(row["status"], "ok")
        self.assertEqual(row["mesh"], 1)
        self.assertEqual(row["mesh_vertices_total"], 248)
        self.assertEqual(row["skinned_mesh_renderer"], 1)
        self.assertEqual(row["skinned_bones_max"], 4)
        self.assertEqual(row["animation_clip"], 1)
        self.assertEqual(row["clip_names"], "Attack")
        self.assertEqual(row["clip_durations_s"], "1.500")
        self.assertEqual(row["mesh_names"], "CreatureMesh")

    def test_corrupt_bundle_is_reported(self):
        def fail(_):
            raise ValueError("invalid UnityFS")
        with patch.dict("sys.modules", {"UnityPy": SimpleNamespace(load=fail)}):
            row = module.inspect(Path("broken.prefab_ab"))
        self.assertEqual(row["status"], "error")
        self.assertIn("invalid UnityFS", row["error"])

if __name__ == "__main__":
    unittest.main()
