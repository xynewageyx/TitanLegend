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
@export var show_armor: bool = true
@export_enum("white", "green", "blue", "yellow", "orange", "purple")
var armor_quality: String = "white"

func _ready() -> void:
    if not build_character():
        push_error("Unable to build character")
        return
    if use_weighted_limbs:
        build_weighted_limbs()
    if use_weighted_torso:
        build_weighted_torso()
    if show_armor:
        build_armor_preview()

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
    # Both upper AND lower rigid pieces would otherwise overlap the skinned mesh.
    for part_name in ["UpperArm_l", "UpperArm_r", "Forearm_l", "Forearm_r", "Thigh_l", "Thigh_r", "Shin_l", "Shin_r"]:
        var rigid := skeleton.get_node_or_null("Attach_" + part_name) as BoneAttachment3D
        if rigid != null:
            rigid.visible = false
    return true

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

func build_armor_preview() -> bool:
    if skeleton == null:
        return false
    var armor := get_node_or_null("ArmorPreview") as TitanArmorPreview
    if armor == null:
        armor = TitanArmorPreview.new()
        armor.name = "ArmorPreview"
        add_child(armor)
    return armor.build_armor(skeleton, armor_quality, hero_class)
