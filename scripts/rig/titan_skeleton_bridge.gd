extends RefCounted
## Non-destructive Skeleton3D bone lookup for imported chibi models.
## This helper does not replace existing equipment sockets or modify GLB resources.
const BONE_ALIASES := {
 "root": ["Root", "root"],
 "hips": ["Hips", "hips"],
 "spine": ["Spine", "spine"],
 "head": ["Head", "head_2", "head"],
 "left_arm": ["Arm_L", "upper_arm.L"],
 "right_arm": ["Arm_R", "upper_arm.R"],
 "left_leg": ["Leg_L", "leg.L"],
 "right_leg": ["Leg_R", "leg.R"]
}

static func find_skeleton(node: Node) -> Skeleton3D:
 if node == null:
  return null
 if node is Skeleton3D:
  return node as Skeleton3D
 for child in node.get_children():
  var found: Skeleton3D = find_skeleton(child)
  if found != null:
   return found
 return null

static func resolve_bone(skeleton: Skeleton3D, role: String) -> int:
 if skeleton == null or not BONE_ALIASES.has(role):
  return -1
 for candidate in BONE_ALIASES[role]:
  var index: int = skeleton.find_bone(candidate)
  if index >= 0:
   return index
 return -1

static func audit(skeleton: Skeleton3D) -> Dictionary:
 var result := {"found": {}, "missing": []}
 for role in BONE_ALIASES:
  var index: int = resolve_bone(skeleton, role)
  if index >= 0:
   result["found"][role] = index
  else:
   result["missing"].append(role)
 return result

static func attach_item(skeleton: Skeleton3D, role: String, item: Node3D) -> BoneAttachment3D:
 if skeleton == null or item == null:
  return null
 var index: int = resolve_bone(skeleton, role)
 if index < 0:
  return null
 var socket_name := "TitanRig_" + role
 var existing: Node = skeleton.get_node_or_null(socket_name)
 if existing != null and not (existing is BoneAttachment3D):
  return null
 var socket: BoneAttachment3D = existing as BoneAttachment3D
 if socket == null:
  socket = BoneAttachment3D.new()
  socket.name = socket_name
  socket.bone_idx = index
  skeleton.add_child(socket)
 elif socket.bone_idx != index:
  return null
 if item.get_parent() != null:
  item.reparent(socket, false)
 else:
  socket.add_child(item)
 item.transform = Transform3D.IDENTITY
 return socket
