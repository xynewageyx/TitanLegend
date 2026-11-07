extends Node3D
## Attach equipment visuals to existing hero marker nodes without changing combat logic.
## Expected optional Marker3D children: RightHandSocket, LeftHandSocket,
## HeadSocket, ChestSocket, BackSocket. Works with animated markers.
const WEAPON_PREVIEW = preload("res://scripts/weapons/procedural_weapon_preview.gd")
const ARMOR_PREVIEW = preload("res://scripts/equipment/chibi_armor_piece.gd")
const HAIR_PREVIEW = preload("res://scripts/equipment/procedural_hairstyle.gd")
const SLOT_NAMES := ["HeadSocket", "ChestSocket", "BackSocket", "ShoulderLeftSocket", "ShoulderRightSocket", "ArmLeftSocket", "ArmRightSocket", "GloveLeftSocket", "GloveRightSocket", "LegLeftSocket", "LegRightSocket", "BootLeftSocket", "BootRightSocket"]
var equipped_nodes: Dictionary = {}
func _socket(name: String) -> Node3D:
    var found := find_child(name, true, false)
    if found is Node3D:
        return found as Node3D
    # Animated bone sockets may be siblings of this equipment controller.
    var hero := get_parent()
    if hero is Node3D:
        found = hero.find_child(name, true, false)
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
    visual.set("weapon_type", clampi(weapon_type, 0, 11))
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

## Hair is cosmetic. It does not change combat or armor slot state.
func equip_hairstyle(style: int, color: Color = Color("#694333")) -> bool:
    var socket := _socket("HeadSocket")
    if socket == null:
        push_warning("Titan Legends: missing HeadSocket for hairstyle")
        return false
    _clear("hair")
    var visual := Node3D.new()
    visual.set_script(HAIR_PREVIEW)
    visual.set("style", clampi(style, 0, 2))
    visual.set("hair_color", color)
    socket.add_child(visual)
    equipped_nodes["hair"] = visual
    return true
