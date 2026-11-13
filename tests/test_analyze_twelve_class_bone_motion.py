import unittest
from tools.analyze_twelve_class_bone_motion import summarize, CLASSES, ACTIONS

def sample_data():
    return {"rows": [
      {"class": name, "action": action, "tracked_bones": [
        {"bone": "Hand_R_2" if name == "death_knight" else "Arm_R",
         "max_rotation_degrees": (62.145 if action == "Attack" else 3.5),
         "max_position_delta": (0.19 if action == "Attack" else 0.02)}
      ]} for name in CLASSES for action in ACTIONS], "errors":[]}

class TestMotionAudit(unittest.TestCase):
    def test_all_classes_valid_and_attack_animated(self):
        self.assertTrue(summarize(sample_data())["valid"])
    def test_missing_action_detected(self):
        source=sample_data()
        source["rows"].pop()
        self.assertFalse(summarize(source)["valid"])
    def test_static_death_knight_attack_detected(self):
        source=sample_data()
        for item in source["rows"]:
            if item["class"]=="death_knight" and item["action"]=="Attack":
                item["tracked_bones"][0]["max_rotation_degrees"]=0.0
                item["tracked_bones"][0]["max_position_delta"]=0.0
        self.assertFalse(summarize(source)["valid"])
    def test_death_knight_idle_remains_advisory(self):
        source=sample_data()
        for item in source["rows"]:
            if item["class"]=="death_knight" and item["action"]=="Idle":
                item["tracked_bones"][0]["max_rotation_degrees"]=0.0
        r=summarize(source)
        self.assertTrue(r["valid"])
        self.assertTrue(any("idle" in item.lower() for item in r["observations"]))

if __name__=="__main__":
    unittest.main()
