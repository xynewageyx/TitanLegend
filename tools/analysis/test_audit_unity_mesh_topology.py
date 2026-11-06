import importlib.util
import struct
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
                m_VertexData=types.SimpleNamespace(m_VertexCount=120),
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


    def test_uint16_and_uint32_index_buffer_validation(self):
        for fmt, code in ((0, "<6H"), (1, "<6I")):
            with self.subTest(fmt=fmt):
                mesh = types.SimpleNamespace(
                    m_IndexFormat=fmt,
                    m_IndexBuffer=struct.pack(code, 0, 1, 2, 2, 3, 0))
                sub = types.SimpleNamespace(
                    firstByte=0, indexCount=6, baseVertex=0)
                check = mod._validate_index_buffer(mesh, [sub], 4)
                self.assertEqual(check["status"], "checked")
                self.assertEqual(check["indices_checked"], 6)
                self.assertEqual(check["invalid_indices"], 0)
                self.assertEqual(mod._validate_index_buffer(mesh, [sub], 3)["invalid_indices"], 1)
                sub.indexCount = 7
                self.assertEqual(mod._validate_index_buffer(mesh, [sub], 4)["status"], "invalid_layout")

    def test_vertex_channel_layout_bounds(self):
        channel = types.SimpleNamespace(dimension=3, stream=0, format=0, offset=0)
        stream = types.SimpleNamespace(stride=12, offset=0)
        vertex_data = types.SimpleNamespace(
            m_VertexCount=4, m_Channels=[channel], m_Streams=[stream],
            m_DataSize=bytes(48))
        mesh = types.SimpleNamespace(m_VertexData=vertex_data)
        self.assertEqual(mod._vertex_layout(mesh)["status"], "checked")
        vertex_data.m_DataSize = bytes(47)
        self.assertEqual(mod._vertex_layout(mesh)["status"], "invalid_layout")
        vertex_data.m_DataSize = bytes(48)
        channel.format = 999
        self.assertEqual(mod._vertex_layout(mesh)["status"], "unknown_format")

    def test_float32_xyz_position_decode(self):
        ch = types.SimpleNamespace(format=0, dimension=3, stream=0, offset=0)
        st = types.SimpleNamespace(stride=12, offset=0)
        vd = types.SimpleNamespace(m_VertexCount=2, m_Channels=[ch],
                                   m_Streams=[st],
                                   m_DataSize=struct.pack("<6f", 0, 1, 2, 3, 5, 7))
        report = mod._decode_positions(types.SimpleNamespace(m_VertexData=vd))
        self.assertEqual(report["status"], "decoded")
        self.assertEqual(report["extent"], [3.0, 4.0, 5.0])
        vd.m_DataSize = struct.pack("<6f", float("nan"), 1, 2, 3, 5, 7)
        self.assertEqual(mod._decode_positions(types.SimpleNamespace(m_VertexData=vd))["nonfinite_positions"], 1)
        vd.m_DataSize = bytes(23)
        self.assertEqual(mod._decode_positions(types.SimpleNamespace(m_VertexData=vd))["status"], "invalid_layout")

if __name__ == "__main__":
    unittest.main()
