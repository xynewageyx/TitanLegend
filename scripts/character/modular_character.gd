extends Node3D
class_name TitanModularCharacter
## Original Titan Legends character assembly; does not include reference-game assets.

const SLOT_NAMES = [
    "hair", "head", "torso", "gloves", "legs", "boots",
    "main_hand", "off_hand", "back"
]
const CLASSES = [
    "warrior", "paladin", "druid", "shaman", "hunter", "rogue",
    "mage", "warlock", "summoner", "priest", "brawler", "death_knight"
]

@export_enum("warrior", "paladin", "druid", "shaman", "hunter", "rogue",
    "mage", "warlock", "summoner", "priest", "brawler", "death_knight")
var hero_class: String = "warrior"
@export var skeleton_path: NodePath = NodePath("Skeleton3D")

var _slots: Dictionary = {}

@export var build_original_prototype_rig: bool = true

func _ready() -> void:
    var skeleton := get_node_or_null(skeleton_path) as Skeleton3D
    if build_original_prototype_rig and skeleton != null and skeleton.get_bone_count() == 0:
        var builder := TitanHumanoidRigBuilder.new()
        if not builder.build_rig(skeleton):
            push_warning("Could not generate Titan Legends prototype rig")
        builder.free()
    for slot_name in SLOT_NAMES:
        _ensure_slot(slot_name)

func _ensure_slot(slot_name: String) -> Node3D:
    if _slots.has(slot_name) and is_instance_valid(_slots[slot_name]):
        return _slots[slot_name]
    var slot := get_node_or_null(NodePath("Slots/" + slot_name)) as Node3D
    if slot == null:
        var slots_root := get_node_or_null("Slots") as Node3D
        if slots_root == null:
            slots_root = Node3D.new()
            slots_root.name = "Slots"
            add_child(slots_root)
        slot = Node3D.new()
        slot.name = slot_name
        slots_root.add_child(slot)
    _slots[slot_name] = slot
    return slot

func equip_scene(slot_name: String, scene: PackedScene) -> bool:
    if not SLOT_NAMES.has(slot_name) or scene == null:
        push_warning("Invalid character slot or missing scene: " + slot_name)
        return false
    var slot := _ensure_slot(slot_name)
    for child in slot.get_children():
        slot.remove_child(child)
        child.queue_free()
    var part := scene.instantiate()
    if not (part is Node3D):
        part.free()
        push_warning("Equipment root must inherit Node3D.")
        return false
    slot.add_child(part)
    return true

func clear_slot(slot_name: String) -> void:
    if not SLOT_NAMES.has(slot_name):
        return
    var slot := _ensure_slot(slot_name)
    for child in slot.get_children():
        slot.remove_child(child)
        child.queue_free()

func validate_character() -> PackedStringArray:
    var issues := PackedStringArray()
    if not CLASSES.has(hero_class):
        issues.append("Unknown class: " + hero_class)
    if not (get_node_or_null(skeleton_path) is Skeleton3D):
        issues.append("Missing Skeleton3D at: " + str(skeleton_path))
    for slot_name in SLOT_NAMES:
        if get_node_or_null(NodePath("Slots/" + slot_name)) == null:
            issues.append("Missing slot: " + slot_name)
    var skeleton := get_node_or_null(skeleton_path) as Skeleton3D
    if skeleton != null and skeleton.get_bone_count() == 0:
        issues.append("Skeleton3D has no bones")
    if build_original_prototype_rig and skeleton != null and skeleton.get_bone_count() > 0:
        var builder := TitanHumanoidRigBuilder.new()
        issues.append_array(builder.validate_rig(skeleton))
        builder.free()
    return issues

## Bone-bound visuals use the dedicated equipment controller. Logical Slots
## remain separate placeholders for future skinned equipment adapters.
func equip_socket_armor(slot_name: String, class_index: int = -1, rarity: int = 0) -> bool:
    var controller := get_node_or_null("EquipmentController") as Node3D
    if controller == null:
        return false
    var idx := class_index if class_index >= 0 else CLASSES.find(hero_class)
    return bool(controller.call("equip_armor_slot", slot_name, max(0, idx), rarity))

func equip_socket_hairstyle(style: int, color: Color = Color("#694333")) -> bool:
    var controller := get_node_or_null("EquipmentController") as Node3D
    if controller == null:
        return false
    return bool(controller.call("equip_hairstyle", style, color))
