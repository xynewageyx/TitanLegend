extends SceneTree
const BRIDGE = preload("res://scripts/rig/titan_skeleton_bridge.gd")

func _initialize() -> void:
 var root := Node3D.new()
 get_root().add_child(root)
 var nested := Node3D.new()
 root.add_child(nested)
 var skeleton := Skeleton3D.new()
 nested.add_child(skeleton)
 for bone_name in ["Root", "Hips", "Spine", "Head", "Arm_L", "Arm_R", "Leg_L", "Leg_R"]:
  skeleton.add_bone(bone_name)
 assert(BRIDGE.find_skeleton(root) == skeleton)
 assert(BRIDGE.resolve_bone(skeleton, "head") == 3)
 assert(BRIDGE.audit(skeleton)["missing"].is_empty())
 var sword := Node3D.new()
 var socket: BoneAttachment3D = BRIDGE.attach_item(skeleton, "right_arm", sword)
 assert(socket != null)
 assert(sword.get_parent() == socket)
 assert(BRIDGE.attach_item(skeleton, "right_arm", sword) == socket)
 var legacy := Skeleton3D.new()
 root.add_child(legacy)
 for bone_name in ["root", "spine", "head_2", "upper_arm.L", "upper_arm.R", "leg.L", "leg.R"]:
  legacy.add_bone(bone_name)
 assert(BRIDGE.resolve_bone(legacy, "head") == 2)
 assert(BRIDGE.resolve_bone(legacy, "hips") == -1)
 assert(BRIDGE.attach_item(legacy, "hips", Node3D.new()) == null)
 print("PASS: skeleton bridge aliases, nested lookup and safe attachments")
 quit()
