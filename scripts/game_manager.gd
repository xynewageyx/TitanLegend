extends Node
signal gold_changed(value: int)
signal tickets_changed(value: int)
signal reincarnation_performed(level: int)
signal jewel_upgraded(level: int)
signal equipment_upgraded(slot: int, level: int)
var current_gold: int = 10000
var reincarnation_tickets: int = 500
var current_reincarnation_level: int = 0
var character_level: int = 1
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
