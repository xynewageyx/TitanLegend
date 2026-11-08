"""Synthetic tests for the read-only Ulala landscape decoder (no reference assets needed)."""
import importlib.util
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "ulala_landscape_decode.py"
spec = importlib.util.spec_from_file_location("ulala_landscape_decode", SCRIPT)
decoder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(decoder)

class FakeType:
    def __init__(self, name):
        self.name = name

class FakeObject:
    def __init__(self, name, payload=None, fail=False, path_id=None):
        self.type = FakeType(name)
        self.path_id = path_id
        self.payload = payload
        self.fail = fail

    def read(self):
        if self.fail:
            raise ValueError("synthetic object read error")
        return self.payload

class Payload:
    def __init__(self, **kwargs):
        self.__dict__.update(kwargs)

class FakeEnvironment:
    def __init__(self, objects):
        self.objects = objects

class FakeUnityPy:
    objects = []
    @classmethod
    def load(cls, path):
        return FakeEnvironment(cls.objects)

class LandscapeDecoderTests(unittest.TestCase):
    def inspect(self, objects):
        FakeUnityPy.objects = objects
        with TemporaryDirectory() as temp:
            path = Path(temp) / "forest.prefab_ab"
            path.write_bytes(b"synthetic")
            return decoder.inspect_bundle(path, FakeUnityPy)

    def test_mesh_and_texture_metadata_without_payload(self):
        result = self.inspect([
            FakeObject("Mesh", Payload(m_Name="tree", m_VertexCount=300,
                                       m_SubMeshes=[object(), object()])),
            FakeObject("Texture2D", Payload(m_Name="leaves", m_Width=256,
                                            m_Height=128, m_MipCount=5)),
        ])
        self.assertEqual(result["status"], "decoded")
        self.assertEqual(result["object_types"], {"Mesh": 1, "Texture2D": 1})
        self.assertEqual(result["numeric_metadata"][0]["m_VertexCount"], 300)
        self.assertEqual(result["numeric_metadata"][0]["submesh_count"], 2)
        self.assertEqual(result["numeric_metadata"][1]["m_Width"], 256)
        self.assertNotIn("m_SubMeshes", result["numeric_metadata"][0])

    def test_read_failure_reports_partial(self):
        result = self.inspect([FakeObject("Mesh", fail=True),
                               FakeObject("GameObject", Payload(m_Name="Forest"))])
        self.assertEqual(result["status"], "partial")
        self.assertEqual(result["object_read_errors"], {"ValueError": 1})
        self.assertEqual(result["object_types"]["GameObject"], 1)

    def test_unreadable_bundle_reports_error(self):
        class BrokenUnityPy:
            @staticmethod
            def load(path):
                raise RuntimeError("bad synthetic bundle")
        with TemporaryDirectory() as temp:
            path = Path(temp) / "bad.prefab_ab"
            path.write_bytes(b"x")
            result = decoder.inspect_bundle(path, BrokenUnityPy)
        self.assertEqual(result["status"], "error")
        self.assertIn("RuntimeError", result["error"])


    def test_texture_stream_metadata_is_recorded_without_bytes(self):
        stream = Payload(path="archive.resS", offset=4096, size=8192)
        result = self.inspect([
            FakeObject("Texture2D", Payload(
                m_Name="water", m_Width=512, m_Height=256,
                m_TextureFormat=47, m_MipCount=9,
                m_CompleteImageSize=8192, m_IsReadable=False,
                m_StreamData=stream, image_data=b"not-exported"))
        ])
        self.assertEqual(result["status"], "decoded")
        meta = result["numeric_metadata"][0]
        self.assertEqual(meta["m_Height"], 256)
        self.assertEqual(meta["m_TextureFormat"], 47)
        self.assertEqual(meta["m_MipCount"], 9)
        self.assertEqual(meta["stream"], {"path": "archive.resS", "offset": 4096, "size": 8192})
        self.assertEqual(meta["embedded_image_bytes"], 12)
        self.assertNotIn("image_data", meta)
        self.assertNotIn("not-exported", str(result))

    def test_texture_path_id_can_identify_unreferenced_resources(self):
        result = self.inspect([
            FakeObject("Texture2D", Payload(m_Name="water_extra",
                       m_Width=128, m_Height=64, m_TextureFormat=10),
                       path_id=2884993606383701065)
        ])
        meta = result["numeric_metadata"][0]
        self.assertEqual(meta["path_id"], 2884993606383701065)
        self.assertEqual(meta["source_bundle"], "forest.prefab_ab")
        self.assertEqual(meta["name"], "water_extra")

    def test_texture_missing_optional_fields(self):
        result = self.inspect([
            FakeObject("Texture2D", Payload(m_Name="minimal", m_Width=32, m_Height=16))
        ])
        self.assertEqual(result["status"], "decoded")
        meta = result["numeric_metadata"][0]
        self.assertNotIn("stream", meta)
        self.assertNotIn("embedded_image_bytes", meta)
        self.assertNotIn("m_TextureFormat", meta)


    def test_mesh_index_and_submesh_structure(self):
        submesh = Payload(firstByte=0, indexCount=6, topology=0,
                          baseVertex=0, firstVertex=0, vertexCount=4)
        vertex_data = Payload(m_VertexCount=4)
        result = self.inspect([
            FakeObject("Mesh", Payload(m_Name="quad", m_VertexCount=4,
                                       m_SubMeshes=[submesh],
                                       m_IndexBuffer=b"\\x00" * 12,
                                       m_IndexFormat=0,
                                       m_VertexData=vertex_data))
        ])
        meta = result["numeric_metadata"][0]
        self.assertEqual(meta["index_buffer_bytes"], 12)
        self.assertEqual(meta["index_format"], 0)
        self.assertEqual(meta["vertex_count"], 4)
        self.assertEqual(meta["submeshes"][0]["index_count"], 6)
        self.assertEqual(meta["submeshes"][0]["topology"], 0)
        self.assertNotIn("m_IndexBuffer", meta)

if __name__ == "__main__":
    unittest.main()
