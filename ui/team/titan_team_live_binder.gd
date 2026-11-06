extends Node
class_name TitanTeamLiveBinder

@export var hud: TitanTeamHUD
@export var battle_manager: Node

func _ready() -> void:
    if hud == null:
        return
    if battle_manager == null:
        var battles := get_tree().get_nodes_in_group("battle_manager")
        if not battles.is_empty():
            battle_manager = battles[0]
    if battle_manager == null:
        return
    if battle_manager.has_signal("battle_status_changed"):
        battle_manager.battle_status_changed.connect(refresh)
    var formation: Node = battle_manager.get("team_formation")
    if formation != null and formation.has_signal("team_changed"):
        formation.team_changed.connect(refresh)
    if GameManager.has_signal("character_level_changed"):
        GameManager.character_level_changed.connect(_on_level_changed)
    refresh()

func _on_level_changed(_level: int) -> void:
    refresh()

func refresh() -> void:
    if hud == null or battle_manager == null:
        return
    var formation: Node = battle_manager.get("team_formation")
    var health: Array = battle_manager.get("hero_hp")
    var maximum: Array = battle_manager.get("hero_max_hp")
    var heroes: Array[Dictionary] = []
    for slot in range(4):
        var title := "Held %d" % (slot + 1)
        var role := "DD"
        if formation != null:
            var classes: Array = formation.get("class_ids")
            var roles: Array = formation.get("role_ids")
            if slot < classes.size():
                var names: Array = ["Krieger", "Paladin", "Druide", "Schamane", "Jaeger", "Schurke", "Magier", "Hexer", "Beschwoerer", "Priester", "Raufbold"] # mirrors TeamFormation class IDs
                var class_id := int(classes[slot])
                if class_id >= 0 and class_id < names.size():
                    title = str(names[class_id])
            if slot < roles.size():
                var role_names: Array = ["Tank", "DD", "Heiler"]
                var role_id := int(roles[slot])
                if role_id >= 0 and role_id < role_names.size():
                    role = str(role_names[role_id])
        var ratio := 0.0
        if slot < health.size() and slot < maximum.size() and int(maximum[slot]) > 0:
            ratio = clampf(float(health[slot]) / float(maximum[slot]), 0.0, 1.0)
        heroes.append({"name": title, "level": GameManager.character_level, "role": role, "hp_ratio": ratio, "leader": slot == 0, "occupied": true})
    hud.update_team(heroes)
