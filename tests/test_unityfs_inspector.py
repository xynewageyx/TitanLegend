"""Unit tests for UnityFS metadata inspection (no proprietary assets required)."""
import importlib.util
import struct
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "inspect_unityfs.py"
spec = importlib.util.spec_from_file_location("inspect_unityfs", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def make_bundle(entry_offset=0, entry_size=4):
    name = b"CAB-test\0"
    info = (b"\0" * 16 + struct.pack(">I", 1)
            + struct.pack(">IIH", 4, 4, 0)
            + struct.pack(">I", 1)
            + struct.pack(">QQI", entry_offset, entry_size, 0) + name)
    header = b"UnityFS\0" + struct.pack(">I", 7) + b"5.x.x\0" + b"2019.4.16f1c1\0"
    # Version 7 metadata begins at the next 16-byte boundary.
    fixed = len(header) + 20
    padding = b"\0" * ((-fixed) % 16)
    total = fixed + len(padding) + len(info) + 4
    return (header + struct.pack(">QIII", total, len(info), len(info), 0)
            + padding + info + b"DATA")


class UnityFSInspectorTests(unittest.TestCase):
    def check_bundle(self, blob):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "fixture.bundle"
            path.write_bytes(blob)
            return module.inspect(path)

    def test_uncompressed_fixture(self):
        result = self.check_bundle(make_bundle())
        self.assertEqual(result["unity"], "2019.4.16f1c1")
        self.assertEqual(result["blocks"], 1)
        self.assertEqual(result["block_codecs"], [0])
        self.assertEqual(result["entries"][0]["name"], "CAB-test")

    def test_rejects_out_of_bounds_directory_entry(self):
        with self.assertRaisesRegex(ValueError, "exceeds"):
            self.check_bundle(make_bundle(entry_offset=2, entry_size=4))

    def test_rejects_wrong_signature(self):
        with self.assertRaises(ValueError):
            self.check_bundle(b"not-a-bundle")


if __name__ == "__main__":
    unittest.main()
