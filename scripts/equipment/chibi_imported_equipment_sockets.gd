extends RefCounted
## Bone-bound positions for Titan Legends' ORIGINAL imported chibi GLBs.
## Eight shared Blender bones (24 on Death Knight) drive the existing inventory.
## A child offset avoids changing BoneAttachment3D's automatically updated pose.
# Resolve installed formation markers directly to avoid circular preloads with
# the equipment controller, which itself imports this socket helper.
const SOCKET_BONES := {
 "RightHandSocket": "Arm_R",
 "LeftHandSocket": "Arm_L",
 "HeadSocket": "Head",
 "ChestSocket": "Spine",
 "BackSocket": "Spine",
 "ShoulderLeftSocket": "Arm_L",
 "ShoulderRightSocket": "Arm_R",
 "ArmLeftSocket": "Arm_L",
 "ArmRightSocket": "Arm_R",
 "GloveLeftSocket": "Arm_L",
 "GloveRightSocket": "Arm_R",
 "LegLeftSocket": "Leg_L",
 "LegRightSocket": "Leg_R",
 "BootLeftSocket": "Leg_L",
 "BootRightSocket": "Leg_R"
}
const ANCHOR_NAME := "EquipmentAnchor"
# The original Death Knight GLB has 24 bones, including a moving second arm
# chain. Other eleven class GLBs use the basic eight-bone armature.
const EXTENDED_BONES := {
 "RightHandSocket": "Hand_R_2",
 "LeftHandSocket": "Hand_L_2",
 "HeadSocket": "Head",
 "ChestSocket": "Chest",
 "BackSocket": "Chest",
 "ShoulderLeftSocket": "UpperArm_L_2",
 "ShoulderRightSocket": "UpperArm_R_2",
 "ArmLeftSocket": "Forearm_L_2",
 "ArmRightSocket": "Forearm_R_2",
 "GloveLeftSocket": "Hand_L_2",
 "GloveRightSocket": "Hand_R_2",
 "LegLeftSocket": "UpperLeg_L_2",
 "LegRightSocket": "UpperLeg_R_2",
 "BootLeftSocket": "Foot_L_2",
 "BootRightSocket": "Foot_R_2"
}

static func selected_bone(skeleton: Skeleton3D, socket_name: String) -> String:
 if skeleton == null or not SOCKET_BONES.has(socket_name):
  return ""
 var preferred: String = EXTENDED_BONES.get(socket_name, "")
 if preferred != "" and skeleton.find_bone(preferred) >= 0:
  return preferred
 var base: String = SOCKET_BONES[socket_name]
 return base if skeleton.find_bone(base) >= 0 else ""

## The GLB faces the +Z camera. Old formation markers were authored with
## the opposite forward axis, causing the rear cape to cover the chest and the
## headpiece to sit like a collar. Calibrate only the imported GLB attachments;
## fallback markers, stats, and other skinning systems are unchanged.
static func calibrated_local_marker(local_pos: Vector3, socket_name: String) -> Vector3:
 match socket_name:
  "BackSocket":
   return Vector3(local_pos.x, local_pos.y, -maxf(0.33, absf(local_pos.z)))
  "ChestSocket":
   return Vector3(local_pos.x, local_pos.y + 0.07, 0.31)
  "HeadSocket":
   return Vector3(local_pos.x, 2.08, -0.04)
  "RightHandSocket":
   return Vector3(0.47, 0.94, 0.02)
  "LeftHandSocket":
   return Vector3(-0.47, 0.94, 0.02)
 return local_pos

static func install(skeleton: Skeleton3D, hero: Node3D) -> bool:
 if skeleton == null or hero == null or not skeleton.is_inside_tree():
  return false
 # Validate every required bone BEFORE creating any sockets, so the caller can
 # safely fall back to the existing synthetic 18-bone equipment rig.
 for socket_name in SOCKET_BONES:
  if selected_bone(skeleton, socket_name) == "":
   return false
  # All fallback markers must already exist before changing the imported GLB.
  if hero.get_node_or_null(NodePath("EquipmentController/" + socket_name)) == null:
   return false
 for socket_name in SOCKET_BONES:
  var existing: Node = skeleton.get_node_or_null(NodePath(socket_name))
  if existing != null:
   if not (existing is BoneAttachment3D):
    return false
   if existing.get_node_or_null(ANCHOR_NAME) == null:
    return false
   continue
  var bone_name: String = selected_bone(skeleton, socket_name)
  var bone_idx: int = skeleton.find_bone(bone_name)
  var joint := BoneAttachment3D.new()
  joint.name = socket_name
  joint.bone_name = bone_name
  skeleton.add_child(joint)
  var anchor := Node3D.new()
  anchor.name = ANCHOR_NAME
  # Convert the existing formation's rest-position marker into the imported
  # bone-local coordinate frame. No vertices, skin matrices or rigs are edited.
  var marker: Node3D = hero.get_node_or_null(NodePath("EquipmentController/" + socket_name)) as Node3D
  var legacy_local: Vector3 = hero.to_local(marker.global_position)
  var calibrated_local: Vector3 = calibrated_local_marker(legacy_local, socket_name)
  var desired_global: Vector3 = hero.to_global(calibrated_local)
  var desired_skeleton_local: Vector3 = skeleton.to_local(desired_global)
  var rest: Transform3D = skeleton.get_bone_global_rest(bone_idx)
  anchor.position = rest.affine_inverse() * desired_skeleton_local
  if socket_name in ["RightHandSocket", "LeftHandSocket"]:
   # Imported Blender bone rest axes are not upright Godot weapon axes.
   # Cancel ONLY the rest rotation; the animated bone delta still moves
   # the weapon after this correction. Armor sockets remain unaffected.
   var rest_world_basis: Basis = (skeleton.global_transform.basis * rest.basis).orthonormalized()
   var desired_world_basis: Basis = hero.global_transform.basis.orthonormalized()
   anchor.basis = rest_world_basis.inverse() * desired_world_basis
  joint.add_child(anchor)
 return true

static func resolve(skeleton: Skeleton3D, socket_name: String) -> Node3D:
 if skeleton == null or not SOCKET_BONES.has(socket_name):
  return null
 var joint := skeleton.get_node_or_null(NodePath(socket_name)) as BoneAttachment3D
 if joint == null or joint.bone_name != selected_bone(skeleton, socket_name):
  return null
 return joint.get_node_or_null(ANCHOR_NAME) as Node3D
