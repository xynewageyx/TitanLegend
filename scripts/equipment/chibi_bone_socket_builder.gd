extends RefCounted
## Attach original equipment sockets to imported 8-bone chibi rigs at runtime.
## No GLB files are modified. Local offsets require visual tuning per model.
const SOCKET_BONES := {
    "RightHandSocket": "Arm_R", "LeftHandSocket": "Arm_L",
    "HeadSocket": "Head", "ChestSocket": "Spine", "BackSocket": "Spine",
    "ShoulderLeftSocket": "Arm_L", "ShoulderRightSocket": "Arm_R",
    "ArmLeftSocket": "Arm_L", "ArmRightSocket": "Arm_R",
    "GloveLeftSocket": "Arm_L", "GloveRightSocket": "Arm_R",
    "LegLeftSocket": "Leg_L", "LegRightSocket": "Leg_R",
    "BootLeftSocket": "Leg_L", "BootRightSocket": "Leg_R"
}
const OFFSETS := {
    "RightHandSocket": Vector3(0.0, -0.18, 0.0),
    "LeftHandSocket": Vector3(0.0, -0.18, 0.0),
    "HeadSocket": Vector3(0.0, 0.12, 0.0),
    "ChestSocket": Vector3(0.0, 0.0, -0.08),
    "BackSocket": Vector3(0.0, 0.0, 0.13),
    "ShoulderLeftSocket": Vector3(0.0, 0.12, 0.0),
    "ShoulderRightSocket": Vector3(0.0, 0.12, 0.0),
    "ArmLeftSocket": Vector3(0.0, -0.06, 0.0),
    "ArmRightSocket": Vector3(0.0, -0.06, 0.0),
    "GloveLeftSocket": Vector3(0.0, -0.18, 0.0),
    "GloveRightSocket": Vector3(0.0, -0.18, 0.0),
    "LegLeftSocket": Vector3(0.0, -0.08, 0.0),
    "LegRightSocket": Vector3(0.0, -0.08, 0.0),
    "BootLeftSocket": Vector3(0.0, -0.23, 0.0),
    "BootRightSocket": Vector3(0.0, -0.23, 0.0)
}

static func ensure_sockets(skeleton: Skeleton3D) -> PackedStringArray:
    var missing := PackedStringArray()
    for socket_name in SOCKET_BONES:
        var bone_name: String = SOCKET_BONES[socket_name]
        var bone_index := skeleton.find_bone(bone_name)
        if bone_index < 0:
            missing.append(socket_name)
            continue
        var existing := skeleton.find_child(socket_name, true, false)
        if existing != null:
            continue
        var attachment := BoneAttachment3D.new()
        attachment.name = socket_name + "Attachment"
        attachment.bone_name = bone_name
        skeleton.add_child(attachment)
        var marker := Marker3D.new()
        marker.name = socket_name
        marker.position = OFFSETS[socket_name]
        attachment.add_child(marker)
    return missing
