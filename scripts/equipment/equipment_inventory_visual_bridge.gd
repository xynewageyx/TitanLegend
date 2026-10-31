extends RefCounted
## Opt-in bridge from existing saved equipment data to cartoon preview meshes.
## Does not modify loot, damage, inventory, save files or tank assignment.
const ADAPTER = preload("res://scripts/equipment/formation_equipment_adapter.gd")
const ARMOR_SLOTS := ["HeadSocket", "ChestSocket", "BackSocket"]
const CLASS_WEAPONS := [1,0,9,8,6,4,8,8,8,9,11]
static func sync_team(team: Node3D) -> int:
    if team == null or not ("heroes" in team) or not ("class_ids" in team):
        return 0
    var updated := 0
    for i in range(mini(4, team.heroes.size())):
        if sync_hero(team.heroes[i], i, int(team.class_ids[i])):
            updated += 1
    return updated
static func sync_hero(hero: Node3D, hero_slot: int, class_id: int) -> bool:
    if hero == null or hero_slot < 0 or hero_slot >= 4:
        return false
    var controller := ADAPTER.install(hero)
    if controller == null:
        return false
    var weapon_rarity := clampi(int(GameManager.weapon_rarities[hero_slot]),0,5)
    controller.equip_weapon(CLASS_WEAPONS[clampi(class_id,0,10)],weapon_rarity)
    # The existing inventory has three loot slots, not thirteen.
    # Map each owned loot item to a distinct visual anchor without inventing items.
    for loot_slot in range(3):
        var anchor: String = ARMOR_SLOTS[loot_slot]
        var item_id := int(GameManager.equipped_loot[hero_slot][loot_slot])
        var item: Dictionary = GameManager.loot_item_by_id(item_id)
        if item.is_empty() or int(item.get("slot",-1)) != loot_slot:
            controller.unequip(anchor)
            continue
        var rarity := clampi(int(item.get("rarity",0)),0,5)
        controller.equip_armor_slot(anchor,clampi(class_id,0,10),rarity)
    return true
