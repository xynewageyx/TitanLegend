extends SceneTree
const PROFILES = preload("res://scripts/character_profiles.gd")
const SLOTS = preload("res://scripts/character_save_slots.gd")

func _initialize() -> void:
 var registry := PROFILES.new_registry()
 assert(PROFILES.create_character(registry, 0, "Held Eins", 0, 0))
 assert(PROFILES.create_character(registry, 1, "Held Zwei", 4, 1))
 var first := SLOTS.initial_save(registry["characters"][0])
 var second := SLOTS.initial_save(registry["characters"][1])
 assert(first["character_level"] == 1 and second["character_level"] == 1)
 assert(first["character_xp"] == 0 and second["character_xp"] == 0)
 assert(first["class_id"] == 0 and second["class_id"] == 4)
 assert(PROFILES.character_save_path(registry, 0) != PROFILES.character_save_path(registry, 1))
 assert(SLOTS.save_slot(registry, 0, {"stage":1,"wave":1,"gold":0,"class_id":4,"role_id":0,"character_level":1}) == ERR_INVALID_DATA)
 assert(SLOTS.save_slot(registry, 0, {"stage":1,"wave":1,"gold":0,"class_id":0,"role_id":1,"character_level":1}) == ERR_INVALID_DATA)
 assert(SLOTS.save_slot(registry, 0, {"stage":1,"wave":1,"gold":0,"class_id":0,"role_id":0,"character_level":0}) == ERR_INVALID_DATA)
 print("Independent character save tests passed")
 quit()
