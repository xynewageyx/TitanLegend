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
        # Angular, bevel-friendly plates instead of generic spherical armor blobs.
        var plate := BoxMesh.new()
        plate.size = Vector3.ONE
        shell.mesh = plate
        shell.scale = _size_for(slot) * bulk
        shell.position = _offset_for(slot)
        var mat := StandardMaterial3D.new()
        mat.albedo_color = armor_color
        mat.metallic = 0.45
        mat.roughness = 0.45
        shell.material_override = mat
        anchor.add_child(shell)
        if tier >= 2 and (slot == "chestplate" or slot.begins_with("shoulder")):
            _add_plate_ridge(anchor, slot, tier, armor_color)
        if tier >= 2 and (slot == "helmet" or slot.begins_with("shoulder")):
            var spike_count: int = int(profile["spikes"]) + (1 if tier >= 4 else 0)
            _add_spikes(anchor, slot, spike_count, tier, armor_color)
        if tier >= 2 and slot == "helmet":
            _add_class_helmet(anchor, hero_class, tier, armor_color)
        if tier >= 3 and slot.begins_with("shoulder"):
            _add_shoulder_fin(anchor, slot, hero_class, tier, armor_color)
        if tier >= 3 and slot == "chestplate":
            _add_emblem(anchor, tier, hero_class, armor_color)
        if tier >= 4 and (slot == "helmet" or slot.begins_with("shoulder")):
            _add_energy_gem(anchor, slot, tier, hero_class)
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

func _add_emblem(anchor: BoneAttachment3D, tier: int, hero_class: String, tint: Color) -> void:
    var emblem := MeshInstance3D.new()
    emblem.name = "ChestEmblem"
    var gem := SphereMesh.new()
    gem.radius = 0.12 + float(tier) * 0.012
    gem.height = gem.radius * 1.65
    emblem.mesh = gem
    emblem.position = Vector3(0, 0.06, -0.36)
    emblem.scale = Vector3(1.0, 1.2, 0.35)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("#8fceff") if hero_class == "paladin" else tint.lightened(0.20)
    if hero_class == "death_knight":
        mat.albedo_color = Color("#9b69ed")
    mat.metallic = 0.4
    emblem.material_override = mat
    anchor.add_child(emblem)

func _add_energy_gem(anchor: BoneAttachment3D, slot: String, tier: int, hero_class: String) -> void:
    var gem := MeshInstance3D.new()
    gem.name = "EnergyGem"
    var shape := SphereMesh.new()
    shape.radius = 0.085 + 0.012 * float(tier - 4)
    shape.height = shape.radius * 2.0
    gem.mesh = shape
    gem.position = Vector3(0, 0.38 if slot == "helmet" else 0.18, -0.24)
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_color = Color("#b783ff") if hero_class == "death_knight" else Color("#75d8ff")
    mat.emission_enabled = true
    mat.emission = mat.albedo_color
    mat.emission_energy_multiplier = 1.0 + float(tier - 4) * 0.6
    gem.material_override = mat
    anchor.add_child(gem)

func _add_plate_ridge(anchor: BoneAttachment3D, slot: String, tier: int, tint: Color) -> void:
    # A raised central ridge makes the armor silhouette visibly faceted.
    var ridge := MeshInstance3D.new()
    ridge.name = "RaisedRidge"
    var ridge_mesh := PrismMesh.new()
    ridge_mesh.size = Vector3(0.16 + tier * 0.025, 0.30 + tier * 0.035, 0.16)
    ridge.mesh = ridge_mesh
    ridge.position = Vector3(0.0, -0.08 if slot == "chestplate" else 0.02, -0.36 if slot == "chestplate" else -0.20)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint.lightened(0.18)
    mat.metallic = 0.5
    mat.roughness = 0.42
    ridge.material_override = mat
    anchor.add_child(ridge)

func _add_class_helmet(anchor: BoneAttachment3D, hero_class: String, tier: int, tint: Color) -> void:
    # Each class belongs to an original, readable cartoon-helmet silhouette family.
    var shape := "crown"
    if hero_class in ["death_knight", "warlock", "summoner"]:
        shape = "horns"
    elif hero_class in ["hunter", "rogue", "druid", "shaman"]:
        shape = "crest"
    elif hero_class in ["mage", "priest"]:
        shape = "circlet"
    var count := 2 if shape == "horns" else 1
    for i in range(count):
        var detail := MeshInstance3D.new()
        detail.name = "ClassHelmetDetail_%d" % i
        var mesh := CylinderMesh.new()
        mesh.radial_segments = 6
        mesh.top_radius = 0.0 if shape != "circlet" else 0.09
        mesh.bottom_radius = 0.10 if shape != "circlet" else 0.12
        mesh.height = 0.22 + 0.065 * float(tier)
        detail.mesh = mesh
        var side := -1.0 if i == 0 else 1.0
        detail.position = Vector3(side * 0.25 if count == 2 else 0.0, 0.67, -0.02)
        if shape == "horns":
            detail.rotation.z = side * -0.42
        elif shape == "crest":
            detail.rotation.x = -0.45
        elif shape == "circlet":
            detail.position.y = 0.57
        var mat := StandardMaterial3D.new()
        mat.albedo_color = tint.lightened(0.28)
        mat.metallic = 0.4
        detail.material_override = mat
        anchor.add_child(detail)

func _add_shoulder_fin(anchor: BoneAttachment3D, slot: String, hero_class: String, tier: int, tint: Color) -> void:
    var fin := MeshInstance3D.new()
    fin.name = "ClassShoulderFin"
    var mesh := PrismMesh.new()
    var heavy := hero_class in ["warrior", "paladin", "brawler", "death_knight"]
    mesh.size = Vector3(0.22 if heavy else 0.12, 0.24 + float(tier) * 0.055, 0.16)
    fin.mesh = mesh
    var side := -1.0 if slot.ends_with("_l") else 1.0
    fin.position = Vector3(side * 0.16, 0.27, 0.0)
    fin.rotation.z = -side * (0.3 if heavy else 0.15)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint.darkened(0.14)
    mat.metallic = 0.5
    fin.material_override = mat
    anchor.add_child(fin)
