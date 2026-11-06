#!/usr/bin/env python3
"""Offline smoke tests for the read-only Unity metadata auditor."""
import importlib.util
import json
import sys
import tempfile
import types
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("audit_unity_metadata.py")
spec = importlib.util.spec_from_file_location("audit_unity_metadata", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class FakeObject:
    def __init__(self, kind, data=None, fail=False):
        self.type = types.SimpleNamespace(name=kind)
        self.data = data
        self.fail = fail

    def read(self):
        if self.fail:
            raise ValueError("simulated bad object")
        return self.data


class MetadataAuditTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)

    def run_audit(self, objects):
        (self.root / "sample.bundle").write_bytes(b"UnityFS\0" + b"0" * 16)
        (self.root / "other.txt").write_text("not a bundle")
        previous = sys.modules.get("UnityPy")
        sys.modules["UnityPy"] = types.SimpleNamespace(
            load=lambda path: types.SimpleNamespace(objects=objects))
        try:
            return module.audit(self.root, 1024 * 1024, 0)
        finally:
            if previous is None:
                del sys.modules["UnityPy"]
            else:
                sys.modules["UnityPy"] = previous

    def test_aggregate_metrics_and_no_source_payload(self):
        objects = [
            FakeObject("Mesh", types.SimpleNamespace(m_VertexCount=1234, m_Name="SECRET_MESH")),
            FakeObject("SkinnedMeshRenderer", types.SimpleNamespace(m_Bones=[1, 2, 3])),
            FakeObject("AnimationClip", types.SimpleNamespace(
                m_StartTime=1.0, m_StopTime=2.5, m_SampleRate=30,
                m_Name="SECRET_CLIP")),
            FakeObject("Material", types.SimpleNamespace(m_Name="SECRET_MATERIAL")),
        ]
        result = self.run_audit(objects)
        self.assertEqual(result["scanned_bundles"], 1)
        self.assertEqual(result["metrics"]["vertices"]["max"], 1234)
        self.assertEqual(result["metrics"]["bones"]["max"], 3)
        self.assertEqual(result["metrics"]["clip_seconds"]["max"], 1.5)
        self.assertEqual(result["metrics"]["clip_fps"]["max"], 30)
        self.assertNotIn("SECRET_", json.dumps(result))

    def test_corrupt_object_is_counted_without_crash(self):
        result = self.run_audit([FakeObject("Mesh", fail=True)])
        self.assertEqual(result["errors"]["object_read_failed"], 1)
        self.assertEqual(result["object_types"]["Mesh"], 1)

    def test_no_unity_files(self):
        (self.root / "readme.txt").write_text("hello")
        sys.modules["UnityPy"] = types.SimpleNamespace(load=lambda _: None)
        try:
            result = module.audit(self.root, 1024, 0)
        finally:
            del sys.modules["UnityPy"]
        self.assertEqual(result["scanned_bundles"], 0)
        self.assertEqual(result["metrics"]["vertices"]["count"], 0)


if __name__ == "__main__":
    unittest.main()
