extends RefCounted
## Opt-in bridge from existing saved equipment data to cartoon preview meshes.
## Does not modify loot, damage, inventory, save files or tank assignment.
const ADAPTER = preload("res://scripts/equipment/formation_equipment_adapter.gd")
const ARMOR_SLOTS := ["HeadSocket", "ChestSocket", "BackSocket", "ShoulderLeftSocket", "ShoulderRightSocket", "ArmLeftSocket", "ArmRightSocket", "GloveLeftSocket", "GloveRightSocket", "LegLeftSocket", "LegRightSocket", "BootLeftSocket", "BootRightSocket"]
const CLASS_WEAPONS := [1,0,9,8,6,4,8,8,8,9,11]
static func sync_team(team: Node3D) -> int:
    if team == null:
        return 0
    var heroes_value: Variant = team.get("heroes")
    var classes_value: Variant = team.get("class_ids")
    if not (heroes_value is Array) or not (classes_value is Array):
        return 0
    var heroes: Array = heroes_value
    var classes: Array = classes_value
    var updated := 0
    for i in range(mini(4, mini(heroes.size(), classes.size()))):
        if sync_hero(heroes[i], i, int(classes[i])):
            updated += 1
    return updated
static func sync_hero(hero: Node3D, hero_slot: int, class_id: int) -> bool:
    if hero == null or hero_slot < 0 or hero_slot >= 4:
        return false
    if hero_slot >= GameManager.equipped_loot.size() or hero_slot >= GameManager.weapon_rarities.size():
        return false
    if GameManager.equipped_loot[hero_slot].size() < ARMOR_SLOTS.size():
        return false
    var controller := ADAPTER.install(hero)
    if controller == null:
        return false
    var weapon_rarity := clampi(int(GameManager.weapon_rarities[hero_slot]),0,5)
    controller.call("equip_weapon", CLASS_WEAPONS[clampi(class_id,0,10)],weapon_rarity)
    # All thirteen loot slots map to separate visual anchors.
    for loot_slot in range(ARMOR_SLOTS.size()):
        var anchor: String = ARMOR_SLOTS[loot_slot]
        var item_id := int(GameManager.equipped_loot[hero_slot][loot_slot])
        var item: Dictionary = GameManager.loot_item_by_id(item_id)
        if item.is_empty() or int(item.get("slot",-1)) != loot_slot:
            controller.call("unequip", anchor)
            continue
        var rarity := clampi(int(item.get("rarity",0)),0,5)
        controller.call("equip_armor_slot", anchor,clampi(class_id,0,10),rarity)
    return true
