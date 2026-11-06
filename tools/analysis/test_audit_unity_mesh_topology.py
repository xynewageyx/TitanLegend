import importlib.util
import sys
import tempfile
import types
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "audit_unity_mesh_topology", Path(__file__).with_name("audit_unity_mesh_topology.py"))
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


class FakeObject:
    def __init__(self, kind, data):
        self.type = types.SimpleNamespace(name=kind)
        self.data = data

    def read(self):
        return self.data


class MeshTopologyTests(unittest.TestCase):
    def test_triangle_lists_and_non_triangle_submeshes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "fixture.bundle").write_bytes(b"UnityFS\0" + b"0" * 16)
            mesh = types.SimpleNamespace(
                m_VertexCount=120,
                m_SubMeshes=[
                    types.SimpleNamespace(indexCount=90, topology=0),
                    types.SimpleNamespace(indexCount=20, topology=1),
                ])
            bones = types.SimpleNamespace(m_Bones=[1, 2, 3, 4])
            original = sys.modules.get("UnityPy")
            sys.modules["UnityPy"] = types.SimpleNamespace(
                load=lambda _: types.SimpleNamespace(objects=[
                    FakeObject("Mesh", mesh),
                    FakeObject("SkinnedMeshRenderer", bones),
                ]))
            try:
                report = mod.inspect(root)
            finally:
                if original is None:
                    sys.modules.pop("UnityPy", None)
                else:
                    sys.modules["UnityPy"] = original
            self.assertEqual(report["metrics"]["vertex_count"]["max"], 120)
            self.assertEqual(report["metrics"]["submesh_count"]["max"], 2)
            self.assertEqual(report["metrics"]["index_count"]["max"], 110)
            self.assertEqual(report["metrics"]["triangle_count"]["max"], 30)
            self.assertEqual(report["metrics"]["skinned_bone_refs"]["max"], 4)
            self.assertEqual(report["submesh_topology_codes"], {"0": 1, "1": 1})


if __name__ == "__main__":
    unittest.main()
