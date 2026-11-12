import unittest
from tools.check_boss_gameplay_camera_report import validate

def example():
    def b():
        return {"valid":True,"viewport_fraction":1.0,"bbox_px":[120,240,150,200],"behind_vertices":0}
    return {
        "valid":True,"hero_count":4,"screenshots":4,
        "source_camera":"res://scripts/camera_follow.gd",
        "boss_art_source":"res://scripts/boss_art.gd",
        "boss_motion_source":"res://scripts/boss_motion.gd",
        "real_android_device_tested":False,"hud_production_validated":False,
        "scenarios":[{
            "scenario":name,"boss_body_box":b(),"boss_warning_box":b(),
            "hero_boxes":[{**b(),"bbox_px":[120,600,150,200]} for _ in range(4)],
            "boss_warning_visible":True,"fov_degrees":56.0,
            "windup_changed_pixels_without_hud_text":250,
            "idle_image":f"boss_{name}_idle.png",
            "windup_image":f"boss_{name}_windup.png",
        } for name in ("fire","earth")]
    }

class BossCameraTests(unittest.TestCase):
    def test_original_assets_camera_pass(self):
        self.assertTrue(validate(example())["valid"])
    def test_missing_boss_warning_fails(self):
        r=example();r["scenarios"][0]["boss_warning_visible"]=False
        self.assertFalse(validate(r)["valid"])
    def test_text_only_warning_fails(self):
        r=example();r["scenarios"][0]["windup_changed_pixels_without_hud_text"]=0
        self.assertFalse(validate(r)["valid"])
    def test_clipped_hero_fails(self):
        r=example();r["scenarios"][1]["hero_boxes"][3]["viewport_fraction"]=0.1
        self.assertFalse(validate(r)["valid"])
    def test_fake_production_hud_claim_fails(self):
        r=example();r["hud_production_validated"]=True
        self.assertFalse(validate(r)["valid"])
    def test_cropped_boss_fails(self):
        r=example()
        r["scenarios"][0]["boss_body_box"]["viewport_fraction"]=0.90
        self.assertFalse(validate(r)["valid"])
    def test_boss_warning_behind_camera_fails(self):
        r=example()
        r["scenarios"][0]["boss_warning_box"]["behind_vertices"]=1
        self.assertFalse(validate(r)["valid"])
    def test_boss_overlaps_diagnostic_hud_fails(self):
        r=example()
        r["scenarios"][0]["boss_warning_box"]["bbox_px"][1]=100
        self.assertFalse(validate(r)["valid"])
    def test_boss_warning_overlaps_team_fails(self):
        r=example()
        r["scenarios"][0]["hero_boxes"][0]["bbox_px"][1]=445
        self.assertFalse(validate(r)["valid"])
    def test_too_small_boss_fails(self):
        r=example();r["scenarios"][0]["boss_body_box"]["bbox_px"][2]=10
        self.assertFalse(validate(r)["valid"])

if __name__=="__main__":
    unittest.main()
