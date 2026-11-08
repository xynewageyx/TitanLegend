@tool
extends Node3D
class_name TitanHumanoidRigBuilder
## Generates an ORIGINAL 18-bone rest skeleton and animated equipment anchors.
## Prototype only; does not provide skinned character meshes or animation clips.
## Run build_rig() in the editor inspector via a temporary editor script or call in a test.

const BONES = [
    ["root", "", Vector3.ZERO],
    ["pelvis", "root", Vector3(0, 0.55, 0)],
    ["spine", "pelvis", Vector3(0, 0.28, 0)],
    ["chest", "spine", Vector3(0, 0.32, 0)],
    ["neck", "chest", Vector3(0, 0.24, 0)],
    ["head", "neck", Vector3(0, 0.22, 0)],
    ["upper_arm_l", "chest", Vector3(-0.30, 0.13, 0)],
    ["lower_arm_l", "upper_arm_l", Vector3(-0.34, -0.10, 0)],
    ["hand_l", "lower_arm_l", Vector3(-0.27, -0.06, 0)],
    ["upper_arm_r", "chest", Vector3(0.30, 0.13, 0)],
    ["lower_arm_r", "upper_arm_r", Vector3(0.34, -0.10, 0)],
    ["hand_r", "lower_arm_r", Vector3(0.27, -0.06, 0)],
    ["upper_leg_l", "pelvis", Vector3(-0.17, -0.17, 0)],
    ["lower_leg_l", "upper_leg_l", Vector3(0, -0.36, 0)],
    ["foot_l", "lower_leg_l", Vector3(0, -0.32, -0.12)],
    ["upper_leg_r", "pelvis", Vector3(0.17, -0.17, 0)],
    ["lower_leg_r", "upper_leg_r", Vector3(0, -0.36, 0)],
    ["foot_r", "lower_leg_r", Vector3(0, -0.32, -0.12)]
]
const ANCHORS = {
    "HeadSocket": "head",
    "ChestSocket": "chest",
    "BackSocket": "chest",
    "ShoulderLeftSocket": "upper_arm_l",
    "ShoulderRightSocket": "upper_arm_r",
    "ArmLeftSocket": "lower_arm_l",
    "ArmRightSocket": "lower_arm_r",
    "GloveLeftSocket": "hand_l",
    "GloveRightSocket": "hand_r",
    "LegLeftSocket": "upper_leg_l",
    "LegRightSocket": "upper_leg_r",
    "BootLeftSocket": "foot_l",
    "BootRightSocket": "foot_r",
    "RightHandSocket": "hand_r",
    "LeftHandSocket": "hand_l",
    # Compatibility with the original four-anchor prototype in PR #103.
    "head_anchor": "head",
    "main_hand_anchor": "hand_r",
    "off_hand_anchor": "hand_l",
    "back_anchor": "chest"
}

func build_rig(skeleton: Skeleton3D) -> bool:
    if skeleton == null:
        push_error("Missing Skeleton3D")
        return false
    if skeleton.get_bone_count() != 0:
        push_warning("Refusing to overwrite a populated skeleton")
        return false
    for item in BONES:
        var bone_name: String = item[0]
        var parent_name: String = item[1]
        var offset: Vector3 = item[2]
        var idx := skeleton.add_bone(bone_name)
        if idx < 0:
            push_error("Cannot add rig bone: " + bone_name)
            return false
        if parent_name != "":
            var parent_idx := skeleton.find_bone(parent_name)
            if parent_idx < 0:
                push_error("Missing rig parent bone: " + parent_name)
                return false
            skeleton.set_bone_parent(idx, parent_idx)
        skeleton.set_bone_rest(idx, Transform3D(Basis.IDENTITY, offset))
    for anchor_name in ANCHORS:
        var attachment := BoneAttachment3D.new()
        attachment.name = anchor_name
        attachment.bone_name = ANCHORS[anchor_name]
        skeleton.add_child(attachment)
    return true

func validate_rig(skeleton: Skeleton3D) -> PackedStringArray:
    var issues := PackedStringArray()
    if skeleton == null:
        issues.append("Skeleton3D missing")
        return issues
    for item in BONES:
        var bone_name: String = item[0]
        var parent_name: String = item[1]
        var idx := skeleton.find_bone(bone_name)
        if idx < 0:
            issues.append("Missing bone: " + bone_name)
        elif parent_name != "" and skeleton.get_bone_parent(idx) != skeleton.find_bone(parent_name):
            issues.append("Wrong parent: " + bone_name)
    for anchor_name in ANCHORS:
        var attachment := skeleton.get_node_or_null(NodePath(anchor_name)) as BoneAttachment3D
        if attachment == null or attachment.bone_name != ANCHORS[anchor_name]:
            issues.append("Missing or incorrect anchor: " + anchor_name)
    return issues
