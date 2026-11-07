extends TitanRiggedBlockout
class_name TitanFullBodyPrototype
## Integrates procedural weighted limb sections with the original character blockout.
## Visual prototype only: not a watertight, production-ready body mesh.

const CHAINS = [
    ["upper_arm_l", "lower_arm_l"],
    ["upper_arm_r", "lower_arm_r"],
    ["upper_leg_l", "lower_leg_l"],
    ["upper_leg_r", "lower_leg_r"]
]

@export var use_weighted_limbs: bool = true
@export var use_weighted_torso: bool = true

func _ready() -> void:
    if not build_character():
        push_error("Unable to build character")
        return
    if use_weighted_limbs:
        build_weighted_limbs()
    if use_weighted_torso:
        build_weighted_torso()

func build_weighted_limbs() -> bool:
    if skeleton == null:
        return false
    var existing := get_node_or_null("WeightedLimbs")
    if existing != null:
        remove_child(existing)
        existing.free()
    var container := Node3D.new()
    container.name = "WeightedLimbs"
    add_child(container)
    for chain in CHAINS:
        var limb := TitanSkinnedLimb.new()
        limb.name = chain[0] + "_skin"
        container.add_child(limb)
        if not limb.build_limb(skeleton, chain[0], chain[1], 0.16):
            remove_child(container)
            container.free()
            return false
    # Avoid rendering the original rigid upper limb sections on top of the skinned ones.
    for bone_name in ["upper_arm_l", "upper_arm_r", "upper_leg_l", "upper_leg_r"]:
        for child in skeleton.get_children():
            if child is BoneAttachment3D and child.name == "Attach_" + _rigid_part_name(bone_name):
                child.visible = false
    return true

func _rigid_part_name(bone_name: String) -> String:
    var prefix := "UpperArm_" if bone_name.begins_with("upper_arm_") else "Thigh_"
    return prefix + bone_name.substr(bone_name.length() - 1)

func build_weighted_torso() -> bool:
    if skeleton == null:
        return false
    var previous := get_node_or_null("WeightedTorso")
    if previous != null:
        remove_child(previous)
        previous.free()
    var torso := TitanSkinnedTorso.new()
    torso.name = "WeightedTorso"
    add_child(torso)
    if not torso.build_torso(skeleton):
        remove_child(torso)
        torso.free()
        return false
    # Hide only the original rigid torso; preserve the hips and other parts.
    for child in skeleton.get_children():
        if child is BoneAttachment3D and child.name == "Attach_Torso":
            child.visible = false
    return true
