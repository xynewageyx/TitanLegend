"""Static checks for animated equipment attachment diagnostics.

These tests confirm diagnostics exist and do not mutate character skeletons.
A runtime rig test with actual character scenes is still required.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class EquipmentSocketDiagnosticsTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.code = (ROOT / "scripts/equipment/hero_equipment_sockets.gd").read_text(encoding="utf-8")

    def test_reports_missing_sockets(self):
        self.assertIn("func missing_equipment_sockets(include_offhand: bool = false) -> PackedStringArray:", self.code)
        self.assertIn('expected.append("LeftHandSocket")', self.code)
        self.assertIn('PackedStringArray(["RightHandSocket"])', self.code)
        self.assertIn("missing.append(socket_name)", self.code)

    def test_identifies_bone_attachments(self):
        self.assertIn("func is_socket_bone_attached(socket_name: String) -> bool:", self.code)
        self.assertIn("if parent is BoneAttachment3D:", self.code)
        self.assertIn("if parent is Skeleton3D:", self.code)

    def test_diagnostics_are_read_only(self):
        diagnostics = self.code.split("func equipment_socket_diagnostics() -> Dictionary:", 1)[1]
        self.assertIn('"not_bone_attached": unbound', diagnostics)
        self.assertNotIn("add_child(", diagnostics)
        self.assertNotIn("remove_child(", diagnostics)
        self.assertNotIn("queue_free(", diagnostics)


if __name__ == "__main__":
    unittest.main()
