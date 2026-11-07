extends GridContainer
class_name TitanTeamHUD

signal hero_selected(hero_index: int)

const CARD_SCENE: PackedScene = preload("res://ui/team/titan_team_card.tscn")
const TEAM_SIZE: int = 4

@export var compact_breakpoint: float = 620.0

func _ready() -> void:
    add_theme_constant_override("h_separation", 6)
    add_theme_constant_override("v_separation", 6)
    resized.connect(_update_columns)
    _ensure_cards()
    _update_columns()

func _ensure_cards() -> void:
    for i in range(TEAM_SIZE):
        var card: TitanTeamCard
        if i < get_child_count() and get_child(i) is TitanTeamCard:
            card = get_child(i) as TitanTeamCard
        else:
            card = CARD_SCENE.instantiate() as TitanTeamCard
            add_child(card)
        card.hero_index = i
        card.is_occupied = false
        card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        if not card.hero_selected.is_connected(_on_hero_selected):
            card.hero_selected.connect(_on_hero_selected)

func _update_columns() -> void:
    columns = 2 if size.x < compact_breakpoint else 4

func update_team(heroes: Array[Dictionary]) -> void:
    _ensure_cards_if_missing()
    for i in range(TEAM_SIZE):
        var card := get_child(i) as TitanTeamCard
        if i < heroes.size():
            var data := heroes[i].duplicate()
            data["occupied"] = bool(data.get("occupied", true))
            card.set_hero(data)
        else:
            card.set_hero({"occupied": false, "leader": false, "hp_ratio": 0.0})

func _ensure_cards_if_missing() -> void:
    if get_child_count() < TEAM_SIZE:
        _ensure_cards()

func _on_hero_selected(index: int) -> void:
    hero_selected.emit(index)
