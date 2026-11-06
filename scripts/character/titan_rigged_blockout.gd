extends Node3D
class_name TitanRiggedBlockout
## Bone-attached original 3D blockout with procedural idle/run/attack motion.
## Rigid bone attachment is NOT smooth mesh skinning.
@export_enum("warrior", "paladin", "druid", "shaman", "hunter", "rogue", "mage", "warlock", "summoner", "priest", "brawler", "death_knight")
var hero_class: String = "warrior"
@export_enum("idle", "run", "attack")
var motion: String = "idle"
@export var animate: bool = true

var skeleton: Skeleton3D
var _elapsed: float = 0.0

func _ready() -> void:
    build_character()

func build_character() -> bool:
    if not TitanModularCharacter.CLASSES.has(hero_class):
        return false
    skeleton = get_node_or_null("Skeleton3D") as Skeleton3D
    if skeleton == null:
        skeleton = Skeleton3D.new()
        skeleton.name = "Skeleton3D"
        add_child(skeleton)
    if skeleton.get_bone_count() == 0:
        var builder := TitanHumanoidRigBuilder.new()
        add_child(builder)
        var success := builder.build_rig(skeleton)
        remove_child(builder)
        builder.free()
        if not success:
            return false
    var old := get_node_or_null("BlockoutParts")
    if old != null:
        remove_child(old)
        old.free()
    var parts := Node3D.new()
    parts.name = "BlockoutParts"
    add_child(parts)
    var heavy: bool = hero_class in ["warrior", "paladin", "brawler", "death_knight"]
    var primary := Color("#4b526e") if hero_class == "death_knight" else Color("#6c8aaf")
    _attach(parts, "head", "Head", Vector3(0, 0.24, 0), Vector3(0.35, 0.37, 0.34), Color("#eac49e"))
    _attach(parts, "chest", "Torso", Vector3(0, -0.10, 0), Vector3(0.42 if heavy else 0.34, 0.35, 0.29), primary)
    _attach(parts, "pelvis", "Hips", Vector3.ZERO, Vector3(0.30, 0.20, 0.26), primary.darkened(0.18))
    for side in ["l", "r"]:
        _attach(parts, "upper_arm_" + side, "UpperArm_" + side, Vector3(0, -0.12, 0), Vector3(0.17, 0.27, 0.17), primary)
        _attach(parts, "lower_arm_" + side, "Forearm_" + side, Vector3(0, -0.11, 0), Vector3(0.15, 0.24, 0.15), primary.lightened(0.12))
        _attach(parts, "hand_" + side, "Hand_" + side, Vector3.ZERO, Vector3.ONE * 0.15, Color("#eac49e"))
        _attach(parts, "upper_leg_" + side, "Thigh_" + side, Vector3(0, -0.14, 0), Vector3(0.19, 0.28, 0.19), primary.darkened(0.10))
        _attach(parts, "lower_leg_" + side, "Shin_" + side, Vector3(0, -0.14, 0), Vector3(0.17, 0.27, 0.17), primary.darkened(0.25))
        _attach(parts, "foot_" + side, "Boot_" + side, Vector3(0, -0.04, -0.09), Vector3(0.20, 0.14, 0.27), primary.darkened(0.4))
    return true

func _attach(parent: Node3D, bone: String, part_name: String, offset: Vector3, dimensions: Vector3, tint: Color) -> void:
    var idx := skeleton.find_bone(bone)
    if idx < 0:
        push_warning("Missing bone: " + bone)
        return
    var attachment := BoneAttachment3D.new()
    attachment.name = "Attach_" + part_name
    attachment.bone_name = bone
    parent.add_child(attachment)
    # BoneAttachment3D must be a child of Skeleton3D to follow its bone.
    parent.remove_child(attachment)
    skeleton.add_child(attachment)
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = part_name
    var mesh := SphereMesh.new()
    mesh.radius = 1.0
    mesh.height = 2.0
    mesh_instance.mesh = mesh
    mesh_instance.position = offset
    mesh_instance.scale = dimensions
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.roughness = 1.0
    mesh_instance.material_override = mat
    attachment.add_child(mesh_instance)

func _process(delta: float) -> void:
    if not animate or skeleton == null:
        return
    _elapsed += delta
    var t := _elapsed
    _pose("upper_arm_l", 0.0)
    _pose("upper_arm_r", 0.0)
    _pose("upper_leg_l", 0.0)
    _pose("upper_leg_r", 0.0)
    if motion == "run":
        var stride := sin(t * 9.0) * 0.45
        _pose("upper_leg_l", stride)
        _pose("upper_leg_r", -stride)
        _pose("upper_arm_l", -stride * 0.7)
        _pose("upper_arm_r", stride * 0.7)
    elif motion == "attack":
        _pose("upper_arm_r", -0.9 + sin(t * 7.0) * 0.6)
    elif motion == "idle":
        _pose("upper_arm_l", sin(t * 2.0) * 0.04)
        _pose("upper_arm_r", -sin(t * 2.0) * 0.04)

func _pose(bone: String, angle: float) -> void:
    var idx := skeleton.find_bone(bone)
    if idx >= 0:
        skeleton.set_bone_pose_rotation(idx, Quaternion(Vector3.RIGHT, angle))
