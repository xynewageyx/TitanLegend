extends Node3D
class_name TitanArmorPreview
## Original stylized armor blockout, attached to an existing Skeleton3D.
## Equipment quality affects silhouette, not combat stats.

const TIERS := ["white", "green", "blue", "yellow", "orange", "purple"]
const SLOTS := {
    "helmet": "head",
    "chestplate": "chest",
    "shoulder_l": "upper_arm_l",
    "shoulder_r": "upper_arm_r",
    "gauntlet_l": "lower_arm_l",
    "gauntlet_r": "lower_arm_r",
    "greave_l": "lower_leg_l",
    "greave_r": "lower_leg_r"
}
const COLORS := [
    Color("#9eabb3"), Color("#5baf73"), Color("#4d91d1"),
    Color("#d5bb55"), Color("#e18b3d"), Color("#9866c6")
]

var skeleton: Skeleton3D

func build_armor(target: Skeleton3D, quality: String = "white") -> bool:
    if target == null or not TIERS.has(quality):
        return false
    for bone_name in SLOTS.values():
        if target.find_bone(bone_name) < 0:
            return false
    skeleton = target
    for child in get_children():
        remove_child(child)
        child.free()
    var tier := TIERS.find(quality)
    var armor_color: Color = COLORS[tier]
    var bulk := 1.0 + float(tier) * 0.14
    for slot in SLOTS:
        var anchor := BoneAttachment3D.new()
        anchor.name = slot
        anchor.bone_name = SLOTS[slot]
        skeleton.add_child(anchor)
        # Armor remains under the skeleton so BoneAttachment3D can follow its bone.
        var shell := MeshInstance3D.new()
        shell.name = "ArmorMesh"
        var sphere := SphereMesh.new()
        sphere.radius = 0.5
        sphere.height = 1.0
        shell.mesh = sphere
        shell.scale = _size_for(slot) * bulk
        shell.position = _offset_for(slot)
        var mat := StandardMaterial3D.new()
        mat.albedo_color = armor_color
        mat.metallic = 0.45
        mat.roughness = 0.45
        shell.material_override = mat
        anchor.add_child(shell)
        # Track created anchors by metadata to clean them on rebuild.
        anchor.set_meta("titan_armor_preview", true)
    return true

func clear_armor() -> void:
    if skeleton == null:
        return
    for child in skeleton.get_children():
        if child is BoneAttachment3D and child.has_meta("titan_armor_preview"):
            skeleton.remove_child(child)
            child.free()

func _size_for(slot: String) -> Vector3:
    if slot == "chestplate":
        return Vector3(0.95, 0.78, 0.70)
    if slot == "helmet":
        return Vector3(0.75, 0.58, 0.72)
    if slot.begins_with("shoulder"):
        return Vector3(0.49, 0.44, 0.51)
    return Vector3(0.35, 0.46, 0.35)

func _offset_for(slot: String) -> Vector3:
    if slot == "helmet":
        return Vector3(0, 0.35, 0)
    if slot == "chestplate":
        return Vector3(0, -0.12, 0)
    return Vector3.ZERO
