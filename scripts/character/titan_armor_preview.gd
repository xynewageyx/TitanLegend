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

const CLASS_STYLE := {
    "warrior": {"bulk": 1.20, "spikes": 2},
    "paladin": {"bulk": 1.16, "spikes": 1},
    "druid": {"bulk": 0.90, "spikes": 1},
    "shaman": {"bulk": 0.96, "spikes": 1},
    "hunter": {"bulk": 0.95, "spikes": 1},
    "rogue": {"bulk": 0.82, "spikes": 1},
    "mage": {"bulk": 0.83, "spikes": 0},
    "warlock": {"bulk": 0.93, "spikes": 2},
    "summoner": {"bulk": 0.90, "spikes": 1},
    "priest": {"bulk": 0.89, "spikes": 0},
    "brawler": {"bulk": 1.12, "spikes": 1},
    "death_knight": {"bulk": 1.30, "spikes": 3}
}

var skeleton: Skeleton3D

func build_armor(target: Skeleton3D, quality: String = "white", hero_class: String = "warrior") -> bool:
    if target == null or not TIERS.has(quality) or not CLASS_STYLE.has(hero_class):
        return false
    for bone_name in SLOTS.values():
        if target.find_bone(bone_name) < 0:
            return false
    clear_armor()
    skeleton = target
    var tier := TIERS.find(quality)
    var armor_color: Color = COLORS[tier]
    var profile: Dictionary = CLASS_STYLE[hero_class]
    var bulk: float = (1.0 + float(tier) * 0.14) * float(profile["bulk"])
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
        if tier >= 2 and (slot == "helmet" or slot.begins_with("shoulder")):
            var spike_count: int = int(profile["spikes"]) + (1 if tier >= 4 else 0)
            _add_spikes(anchor, slot, spike_count, tier, armor_color)
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

func _add_spikes(anchor: BoneAttachment3D, slot: String, count: int, tier: int, tint: Color) -> void:
    if count <= 0:
        return
    for i in range(count):
        var spike := MeshInstance3D.new()
        spike.name = "Spike_%d" % i
        var cone := CylinderMesh.new()
        cone.top_radius = 0.0
        cone.bottom_radius = 0.07 + float(tier) * 0.015
        cone.height = 0.18 + float(tier) * 0.065
        cone.radial_segments = 6
        spike.mesh = cone
        var spread := float(i) - float(count - 1) * 0.5
        spike.position = Vector3(spread * 0.16, 0.30 + cone.height * 0.5, 0.0)
        if slot == "helmet":
            spike.position.y += 0.22
        spike.rotation.z = -spread * 0.24
        var material := StandardMaterial3D.new()
        material.albedo_color = tint.darkened(0.22)
        material.metallic = 0.55
        spike.material_override = material
        anchor.add_child(spike)
