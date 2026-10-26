"""Static checks for class-specific fantasy costume meshes."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
COSTUMES = (ROOT / "scripts/hero_fantasy_costumes.gd").read_text(encoding="utf-8")
TEAM = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")


class FantasyCostumeTests(unittest.TestCase):
    def test_all_classes_receive_new_meshes(self):
        self.assertIn('preload("res://scripts/hero_fantasy_costumes.gd").decorate(hero, class_id, selected_role, slot)', TEAM)
        for marker in ("CylinderMesh.new()", "mesh.radial_segments = 7", "match class_id:", "var emblem :="):
            self.assertIn(marker, COSTUMES)

    def test_rounded_capes_replace_boxy_back_panels(self):
        silhouettes = (ROOT / "scripts/hero_silhouette_v2.gd").read_text(encoding="utf-8")
        self.assertIn('cape.name = "HeroCape"', silhouettes)
        self.assertIn("cape_mesh.bottom_radius = 0.57", silhouettes)
        self.assertIn("cape_mesh.top_radius = 0.32", silhouettes)
        self.assertNotIn('_box(hero, Vector3(0.83, 1.23, 0.07)', silhouettes)

    def test_face_and_body_proportions(self):
        team = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")
        faces = (ROOT / "scripts/hero_faces_hands_70.gd").read_text(encoding="utf-8")
        self.assertIn("torso.scale = Vector3(0.94, 1.26, 0.69)", team)
        self.assertIn("head.scale = Vector3(1.12, 1.16, 0.92)", team)
        for marker in ("var ear :=", "var cheek :=", "var mouth :="):
            self.assertIn(marker, faces)

    def test_costumes_are_visual_only(self):
        self.assertNotIn("damage", COSTUMES)
        self.assertNotIn("cooldown", COSTUMES)
        self.assertNotIn("CollisionShape3D", COSTUMES)


if __name__ == "__main__":
    unittest.main()
