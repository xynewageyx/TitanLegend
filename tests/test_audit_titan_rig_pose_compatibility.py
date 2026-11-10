"""Tests for imported twelve-class rest-pose compatibility and socket checks."""
import copy
import unittest
from tools.audit_titan_rig_pose_compatibility import audit, CLASSES, BASE, EXTENDED

def make_bones(extended=False):
    parents = {"Root": None, "Hips":"Root", "Spine":"Hips", "Head":"Spine",
               "Arm_L":"Spine", "Arm_R":"Spine", "Leg_L":"Hips", "Leg_R":"Hips"}
    if extended:
        parents.update({"Chest":"Spine", "Neck":"Chest",
                        "Head":"Neck", "Arm_L":"Chest", "Arm_R":"Chest"})
        for side in ["L","R"]:
            parents.update({"Shoulder_"+side:"Arm_"+side,
                            "UpperArm_"+side+"_2":"Shoulder_"+side,
                            "Forearm_"+side+"_2":"UpperArm_"+side+"_2",
                            "Hand_"+side+"_2":"Forearm_"+side+"_2",
                            "UpperLeg_"+side+"_2":"Leg_"+side,
                            "LowerLeg_"+side+"_2":"UpperLeg_"+side+"_2",
                            "Foot_"+side+"_2":"LowerLeg_"+side+"_2"})
    bones=[]
    for i,(name,parent) in enumerate(parents.items()):
        bones.append({"index":i,"name":name,"parent":parent,
                      "rest_origin":[0.0,0.1,0.0],
                      "rest_basis":[[1,0,0],[0,1,0],[0,0,1]]})
    return bones

def fixtures():
    return {"skeletons":[{"scene":"res://assets/heroes/chibi/"+name+".glb",
                          "bones":make_bones(name=="death_knight")}
                         for name in CLASSES]}

class PoseCompatibilityTests(unittest.TestCase):
    def test_standard_and_extended(self):
        result=audit(fixtures())
        self.assertTrue(result["valid"],result["errors"])
        for row in result["classes"][:-1]:
            self.assertEqual(row["bone_count"],8)
            self.assertTrue(row["compatible_with_standard_rest"])
            self.assertEqual(row["missing_socket_bones"],[])
        dk=result["classes"][-1]
        self.assertEqual(dk["bone_count"],24)
        self.assertEqual(dk["shared_named_bones"],8)
        self.assertFalse(dk["compatible_with_standard_rest"])
        self.assertEqual(dk["missing_socket_bones"],[])
        self.assertFalse(result["retargeting_verified"])
    def test_change_to_base_rest_rejected(self):
        data=fixtures()
        data["skeletons"][1]["bones"][1]["rest_origin"][0]=0.2
        r=audit(data)
        self.assertFalse(r["valid"])
        self.assertIn("Hips",r["classes"][1]["base_rest_mismatches"])
    def test_missing_death_knight_hand_detected(self):
        data=fixtures()
        bones=data["skeletons"][-1]["bones"]
        bones[:]=[b for b in bones if b["name"]!="Hand_R_2"]
        r=audit(data)
        self.assertFalse(r["valid"])
        self.assertIn("RightHandSocket",r["classes"][-1]["missing_socket_bones"])
    def test_duplicate_class_rejected(self):
        data=fixtures()
        data["skeletons"].append(copy.deepcopy(data["skeletons"][0]))
        self.assertFalse(audit(data)["valid"])
    def test_missing_class_rejected(self):
        data=fixtures()
        data["skeletons"].pop()
        self.assertFalse(audit(data)["valid"])

if __name__=="__main__":
    unittest.main()
