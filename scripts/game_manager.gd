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
# Four equipment-hardening fields per hero: attack, armor, max HP, critical damage.
var hardening_levels: Array = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
const HARDENING_NAMES := ["Angriff", "Ruestung", "Lebenspunkte", "Krit-Schaden"]
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
 return minf(0.15, float(weapon_levels[slot]) * 0.0005)

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

func hardening_bonus(hero: int, field: int) -> float:
 if hero < 0 or hero >= 4 or field < 0 or field >= 4:
  return 0.0
 return minf(0.20, float(hardening_levels[hero][field]) * 0.0002)

func upgrade_hardening(hero: int, field: int) -> bool:
 var cost: int = hardening_upgrade_cost(hero, field)
 if cost <= 0 or current_gold < cost:
  return false
 add_gold(-cost)
 hardening_levels[hero][field] = int(hardening_levels[hero][field]) + 1
 equipment_upgraded.emit(hero, int(hardening_levels[hero][field]))
 SaveManager.save_game()
 return true
