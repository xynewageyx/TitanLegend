import unittest
from tools.check_gameplay_camera_benchmark import validate

def fixture():
    return {
        "valid": True,
        "camera": {"source_script": "res://scripts/camera_follow.gd",
                   "projection": "perspective", "fov_degrees": 56.0},
        "captures": [
            {"pose": action, "frame_width":720, "frame_height":1280,
             "body_visibility":[{"class":name} for name in ("warrior","mage","death_knight","druid")],
             "minimum_body_viewport_fraction":0.87}
            for action in ("idle","attack")
        ],
        "benchmark": {"warmup_frames":20,"measured_frames":90,"mean_frame_ms":21.5,
                      "median_frame_ms":20,"p95_frame_ms":27,"estimated_mean_fps":46.5,
                      "renderer":"Godot Mesa Linux","real_android_device_tested":False}
    }

class BenchmarkAuditTests(unittest.TestCase):
    def test_correct_capture_is_valid(self):
        self.assertTrue(validate(fixture())["valid"])
    def test_wrong_camera_is_rejected(self):
        data=fixture();data["camera"]["source_script"]="res://tools/qa_camera.gd"
        self.assertFalse(validate(data)["valid"])
    def test_android_fps_claim_is_rejected(self):
        data=fixture();data["benchmark"]["real_android_device_tested"]=True
        self.assertFalse(validate(data)["valid"])
    def test_insufficient_frame_count_is_rejected(self):
        data=fixture();data["benchmark"]["measured_frames"]=1
        self.assertFalse(validate(data)["valid"])
    def test_missing_character_captures_rejected(self):
        data=fixture();data["captures"][1]["body_visibility"].pop()
        self.assertFalse(validate(data)["valid"])

if __name__=="__main__":
    unittest.main()
