extends Node
const EXPERIENCE = preload("res://scripts/experience_system.gd")
signal gold_changed(value: int)
signal xp_changed(current_xp: int)
signal character_level_changed(new_level: int)
signal tickets_changed(value: int)
signal reincarnation_performed(level: int)
signal jewel_upgraded(level: int)
signal equipment_upgraded(slot: int, level: int)
var current_gold: int = 10000
var reincarnation_tickets: int = 500
var current_reincarnation_level: int = 0
var character_level: int = 1
var character_xp: int = 0
var jewel_level: int = 1
# Initial weapon upgrade track, independently stored for each hero.
var weapon_levels: Array[int] = [0, 0, 0, 0]
const MAX_WEAPON_LEVEL: int = 300
# Six independent weapon qualities. Each promotion keeps the existing weapon level.
const WEAPON_RARITIES := ["Weiss", "Gruen", "Blau", "Gelb", "Gold", "Lila"]
const WEAPON_RARITY_BONUS := [0.0, 0.01, 0.025, 0.045, 0.07, 0.10]
const WEAPON_RARITY_LEVELS := [0, 20, 50, 100, 180, 260]
const WEAPON_RARITY_COSTS := [10000, 50000, 200000, 800000, 2000000]
var weapon_rarities: Array[int] = [0, 0, 0, 0]
# Four equipment-hardening fields per hero: attack, armor, max HP, critical damage.
var hardening_levels: Array = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
const HARDENING_NAMES := ["Angriff", "Ruestung", "Lebenspunkte", "Krit-Schaden", "Ausweichen", "Aufspiessen"]
# Legacy save files already have four fields, mapped to their original attributes.
var hardening_attributes: Array = [[0,1,2,3],[0,1,2,3],[0,1,2,3],[0,1,2,3]]
const MAX_R: int = 5
func add_gold(amount: int) -> void:
 current_gold = maxi(0, current_gold + amount)
 gold_changed.emit(current_gold)
func xp_for_next_level() -> int:
 return EXPERIENCE.xp_for_next_level(character_level)

func gain_character_xp(amount: int) -> int:
 if amount <= 0:
  return 0
 var result: Dictionary = EXPERIENCE.apply_xp(character_level, character_xp, amount)
 character_level = int(result["level"])
 character_xp = int(result["xp"])
 xp_changed.emit(character_xp)
 var levels: int = int(result["levels_gained"])
 if levels > 0:
  character_level_changed.emit(character_level)
 return levels

func gain_boss_level() -> void:
 # Erhaelt die bisherige Bossbelohnung von genau einem Charakterlevel.
 character_level += 1
 character_level_changed.emit(character_level)
 xp_changed.emit(character_xp)

func add_tickets(amount: int) -> void:
 reincarnation_tickets = maxi(0, reincarnation_tickets + amount)
 tickets_changed.emit(reincarnation_tickets)
func get_next_reincarnation_cost() -> int:
 return (current_reincarnation_level + 1) * 100
func try_perform_reincarnation() -> bool:
 if current_reincarnation_level >= MAX_R or reincarnation_tickets < get_next_reincarnation_cost():
  return false
 add_tickets(-get_next_reincarnation_cost())
 current_reincarnation_level += 1
 reincarnation_performed.emit(current_reincarnation_level)
 SaveManager.save_game()
 return true
func upgrade_jewel() -> bool:
 var cost: int = 250 * jewel_level
 if current_gold < cost:
  return false
 add_gold(-cost)
 jewel_level += 1
 jewel_upgraded.emit(jewel_level)
 SaveManager.save_game()
 return true

func weapon_upgrade_cost(slot: int) -> int:
 if slot < 0 or slot >= weapon_levels.size() or weapon_levels[slot] >= MAX_WEAPON_LEVEL:
  return 0
 return 500 * (weapon_levels[slot] + 1)

func weapon_attack_bonus(slot: int) -> float:
 if slot < 0 or slot >= weapon_levels.size():
  return 0.0
 return minf(0.25, float(weapon_levels[slot]) * 0.0005 + float(WEAPON_RARITY_BONUS[weapon_rarities[slot]]))

func upgrade_weapon(slot: int) -> bool:
 var cost: int = weapon_upgrade_cost(slot)
 if cost <= 0 or current_gold < cost:
  return false
 add_gold(-cost)
 weapon_levels[slot] += 1
 equipment_upgraded.emit(slot, weapon_levels[slot])
 SaveManager.save_game()
 return true

func hardening_upgrade_cost(hero: int, field: int) -> int:
 if hero < 0 or hero >= 4 or field < 0 or field >= 4:
  return 0
 var level: int = int(hardening_levels[hero][field])
 if level >= maxi(1, character_level):
  return 0
 return 1000 * (level + 1)

func hardening_bonus(hero: int, attribute: int) -> float:
 if hero < 0 or hero >= 4 or attribute < 0 or attribute >= HARDENING_NAMES.size():
  return 0.0
 var ranks: int = 0
 for field in range(4):
  if int(hardening_attributes[hero][field]) == attribute:
   ranks += int(hardening_levels[hero][field])
 return minf(0.20, float(ranks) * 0.0002)

func hardening_reroll_cost(hero: int, field: int) -> int:
 if hero < 0 or hero >= 4 or field < 0 or field >= 4:
  return 0
 return 250 * (int(hardening_levels[hero][field]) + 1)

func select_hardening_attribute(hero: int, field: int, attribute: int) -> bool:
 # Choosing a specific attribute is a gold service; ranks remain intact.
 if hero < 0 or hero >= 4 or field < 0 or field >= 4 or attribute < 0 or attribute >= HARDENING_NAMES.size():
  return false
 if int(hardening_attributes[hero][field]) == attribute:
  return false
 var cost: int = hardening_reroll_cost(hero, field)
 if current_gold < cost:
  return false
 add_gold(-cost)
 hardening_attributes[hero][field] = attribute
 equipment_upgraded.emit(hero, int(hardening_levels[hero][field]))
 SaveManager.save_game()
 return true

func reroll_hardening_attribute(hero: int, field: int) -> bool:
 if hero < 0 or hero >= 4 or field < 0 or field >= 4:
  return false
 var cost: int = hardening_reroll_cost(hero, field)
 if current_gold < cost:
  return false
 var previous: int = int(hardening_attributes[hero][field])
 var rolled: int = randi_range(0, HARDENING_NAMES.size() - 2)
 if rolled >= previous:
  rolled += 1
 add_gold(-cost)
 hardening_attributes[hero][field] = rolled
 equipment_upgraded.emit(hero, int(hardening_levels[hero][field]))
 SaveManager.save_game()
 return true

func upgrade_hardening(hero: int, field: int) -> bool:
 var cost: int = hardening_upgrade_cost(hero, field)
 if cost <= 0 or current_gold < cost:
  return false
 add_gold(-cost)
 hardening_levels[hero][field] = int(hardening_levels[hero][field]) + 1
 equipment_upgraded.emit(hero, int(hardening_levels[hero][field]))
 SaveManager.save_game()
 return true

func weapon_rarity_upgrade_cost(slot: int) -> int:
 if slot < 0 or slot >= weapon_rarities.size():
  return 0
 var current: int = weapon_rarities[slot]
 if current >= WEAPON_RARITIES.size() - 1:
  return 0
 if weapon_levels[slot] < int(WEAPON_RARITY_LEVELS[current + 1]):
  return 0
 return int(WEAPON_RARITY_COSTS[current])

func upgrade_weapon_rarity(slot: int) -> bool:
 var cost: int = weapon_rarity_upgrade_cost(slot)
 if cost <= 0 or current_gold < cost:
  return false
 add_gold(-cost)
 weapon_rarities[slot] += 1
 equipment_upgraded.emit(slot, weapon_levels[slot])
 SaveManager.save_game()
 return true

# Update 197: boss equipment drops. Weapons remain a separate upgrade track.
signal loot_changed
const LOOT_SLOTS := ["Helm", "Ruestung", "Zubehoer"]
const MAX_LOOT_ITEMS: int = 60
var equipment_inventory: Array = []
# Each hero references item IDs, not inventory indices, so sorting cannot unequip items.
var equipped_loot: Array = [[-1,-1,-1],[-1,-1,-1],[-1,-1,-1],[-1,-1,-1]]
var next_loot_id: int = 1

func boss_loot_rarity(stage: int) -> int:
 var roll: float = randf()
 var bonus: float = minf(0.10, float(maxi(0, stage - 1)) / 12000.0)
 if roll < 0.003 + bonus * 0.10: return 5
 if roll < 0.018 + bonus * 0.20: return 4
 if roll < 0.070 + bonus * 0.40: return 3
 if roll < 0.200 + bonus * 0.70: return 2
 if roll < 0.480 + bonus: return 1
 return 0

func grant_boss_loot(stage: int, fusion: bool) -> Dictionary:
 # Boss-only, bounded inventory; a full bag does not destroy anything.
 if equipment_inventory.size() >= MAX_LOOT_ITEMS:
  return {}
 var drop_chance: float = 0.85 if fusion else 0.55
 if randf() >= drop_chance:
  return {}
 var item: Dictionary = {
  "id": next_loot_id,
  "slot": randi_range(0, LOOT_SLOTS.size() - 1),
  "rarity": boss_loot_rarity(stage),
  "level": clampi(stage, 1, 1200)
 }
 next_loot_id += 1
 equipment_inventory.append(item)
 loot_changed.emit()
 return item

func loot_item_by_id(item_id: int) -> Dictionary:
 for value in equipment_inventory:
  if value is Dictionary and int(value.get("id", -1)) == item_id:
   return value
 return {}

func equip_loot(hero: int, item_id: int) -> bool:
 if hero < 0 or hero >= 4:
  return false
 var item: Dictionary = loot_item_by_id(item_id)
 if item.is_empty():
  return false
 var slot: int = int(item.get("slot", -1))
 if slot < 0 or slot >= LOOT_SLOTS.size():
  return false
 # An item can only be worn by one hero at a time.
 for h in range(4):
  for i in range(LOOT_SLOTS.size()):
   if int(equipped_loot[h][i]) == item_id:
    equipped_loot[h][i] = -1
 equipped_loot[hero][slot] = item_id
 loot_changed.emit()
 SaveManager.save_game()
 return true

func loot_bonus(hero: int, slot: int) -> float:
 if hero < 0 or hero >= 4 or slot < 0 or slot >= LOOT_SLOTS.size():
  return 0.0
 var item: Dictionary = loot_item_by_id(int(equipped_loot[hero][slot]))
 if item.is_empty() or int(item.get("slot", -1)) != slot:
  return 0.0
 return loot_item_bonus(item)

func loot_item_bonus(item: Dictionary) -> float:
 if item.is_empty():
  return 0.0
 var rarity: int = clampi(int(item.get("rarity", 0)), 0, 5)
 var level: int = clampi(int(item.get("level", 1)), 1, 1200)
 return minf(0.12, float(rarity + 1) * 0.008 + float(level) * 0.000015)

func loot_sale_price(item: Dictionary) -> int:
 if item.is_empty():
  return 0
 var rarity: int = clampi(int(item.get("rarity", 0)), 0, 5)
 var level: int = clampi(int(item.get("level", 1)), 1, 1200)
 return level * (20 + 10 * rarity)

func is_loot_equipped(item_id: int) -> bool:
 for hero in range(4):
  for slot in range(LOOT_SLOTS.size()):
   if int(equipped_loot[hero][slot]) == item_id:
    return true
 return false

func sell_loot(item_id: int) -> bool:
 var item: Dictionary = loot_item_by_id(item_id)
 if item.is_empty() or is_loot_equipped(item_id):
  return false
 var price: int = loot_sale_price(item)
 if price <= 0:
  return false
 for i in range(equipment_inventory.size()):
  if int(equipment_inventory[i].get("id", -1)) == item_id:
   equipment_inventory.remove_at(i)
   add_gold(price)
   loot_changed.emit()
   SaveManager.save_game()
   return true
 return false

func compare_loot(hero: int, item_id: int) -> Dictionary:
 if hero < 0 or hero >= 4:
  return {}
 var item: Dictionary = loot_item_by_id(item_id)
 if item.is_empty():
  return {}
 var slot: int = int(item.get("slot", -1))
 if slot < 0 or slot >= LOOT_SLOTS.size():
  return {}
 var current_item: Dictionary = loot_item_by_id(int(equipped_loot[hero][slot]))
 var candidate_bonus: float = loot_item_bonus(item)
 var worn_bonus: float = loot_item_bonus(current_item)
 return {
  "slot_name": LOOT_SLOTS[slot],
  "candidate": candidate_bonus,
  "equipped": worn_bonus,
  "difference": candidate_bonus - worn_bonus,
  "equipped_name": loot_item_name(current_item)
 }

func loot_item_name(item: Dictionary) -> String:
 if item.is_empty():
  return "Leer"
 var quality: int = clampi(int(item.get("rarity", 0)), 0, 5)
 var slot: int = clampi(int(item.get("slot", 0)), 0, 2)
 return "%s %s (Stufe %d)" % [WEAPON_RARITIES[quality], LOOT_SLOTS[slot], int(item.get("level", 1))]

func loot_equipped_hero(item_id: int) -> int:
 for hero in range(4):
  for slot in range(LOOT_SLOTS.size()):
   if int(equipped_loot[hero][slot]) == item_id:
    return hero
 return -1
