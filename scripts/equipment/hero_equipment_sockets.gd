extends Node3D
## Attach equipment visuals to existing hero marker nodes without changing combat logic.
## Expected optional Marker3D children: RightHandSocket, LeftHandSocket,
## HeadSocket, ChestSocket, BackSocket. Works with animated markers.\n## For Skeleton3D, attach Marker3D sockets below BoneAttachment3D nodes.
const WEAPON_PREVIEW = preload("res://scripts/weapons/procedural_weapon_preview.gd")
const ARMOR_PREVIEW = preload("res://scripts/equipment/chibi_armor_piece.gd")
const SLOT_NAMES := ["HeadSocket", "ChestSocket", "BackSocket", "ShoulderLeftSocket", "ShoulderRightSocket", "ArmLeftSocket", "ArmRightSocket", "GloveLeftSocket", "GloveRightSocket", "LegLeftSocket", "LegRightSocket", "BootLeftSocket", "BootRightSocket"]
var equipped_nodes: Dictionary = {}
func _socket(name: String) -> Node3D:
    var found := find_child(name, true, false)
    return found as Node3D if found is Node3D else null
func equip_weapon(weapon_type: int, rarity: int, offhand: bool = false) -> bool:
    var socket := _socket("LeftHandSocket" if offhand else "RightHandSocket")
    if socket == null:
        push_warning("Titan Legends: missing weapon socket")
        return false
    var key := "offhand" if offhand else "mainhand"
    _clear(key)
    var visual := Node3D.new()
    visual.set_script(WEAPON_PREVIEW)
    visual.set("weapon_type", clampi(weapon_type, 0, 12))
    visual.set("rarity", clampi(rarity, 0, 5))
    socket.add_child(visual)
    equipped_nodes[key] = visual
    return true
func equip_armor_slot(slot: String, hero_class: int, rarity: int) -> bool:
    if not SLOT_NAMES.has(slot):
        return false
    var socket := _socket(slot)
    if socket == null:
        push_warning("Titan Legends: missing armor socket " + slot)
        return false
    _clear(slot)
    var visual := Node3D.new()
    visual.set_script(ARMOR_PREVIEW)
    visual.set("slot_index", SLOT_NAMES.find(slot))
    visual.set("class_id", clampi(hero_class, 0, 11))
    visual.set("rarity", clampi(rarity, 0, 5))
    socket.add_child(visual)
    equipped_nodes[slot] = visual
    return true
func unequip(slot: String) -> void:
    _clear(slot)
func _clear(slot: String) -> void:
    if equipped_nodes.has(slot):
        var node: Node = equipped_nodes[slot]
        if is_instance_valid(node):
            node.queue_free()
        equipped_nodes.erase(slot)

## Validate optional animated attachment points without changing hero rigs.
## Returns socket names missing from this character instance.
func missing_equipment_sockets(include_offhand: bool = false) -> PackedStringArray:
    var missing := PackedStringArray()
    var expected := PackedStringArray(["RightHandSocket"])
    if include_offhand:
        expected.append("LeftHandSocket")
    for slot in SLOT_NAMES:
        expected.append(slot)
    for socket_name in expected:
        if _socket(socket_name) == null:
            missing.append(socket_name)
    return missing

## A Marker3D under BoneAttachment3D follows the animation bone.
## Returns false for missing sockets and for non-bone-mounted sockets.
func is_socket_bone_attached(socket_name: String) -> bool:
    var marker := _socket(socket_name)
    if marker == null:
        return false
    var parent: Node = marker.get_parent()
    while parent != null:
        if parent is BoneAttachment3D:
            return true
        if parent is Skeleton3D:
            break
        parent = parent.get_parent()
    return false

## Read-only diagnostics for character artists and animation QA.
func equipment_socket_diagnostics() -> Dictionary:
    var missing := missing_equipment_sockets(true)
    var unbound := PackedStringArray()
    for socket_name in SLOT_NAMES:
        if _socket(socket_name) != null and not is_socket_bone_attached(socket_name):
            unbound.append(socket_name)
    for hand_name in ["RightHandSocket", "LeftHandSocket"]:
        if _socket(hand_name) != null and not is_socket_bone_attached(hand_name):
            unbound.append(hand_name)
    return {"missing": missing, "not_bone_attached": unbound}
