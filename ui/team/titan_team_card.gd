extends PanelContainer
class_name TitanTeamCard

signal hero_selected(hero_index: int)

@export_range(0, 3) var hero_index: int = 0
@export var hero_name: String = "Held":
    set(value):
        hero_name = value
        _refresh()
@export_range(1, 999) var hero_level: int = 1:
    set(value):
        hero_level = value
        _refresh()
@export var hero_role: String = "DD":
    set(value):
        hero_role = value
        _refresh()
@export_range(0.0, 1.0, 0.01) var health_fraction: float = 1.0:
    set(value):
        health_fraction = clampf(value, 0.0, 1.0)
        _refresh()
@export var is_leader: bool = false:
    set(value):
        is_leader = value
        _refresh()
@export var is_occupied: bool = true:
    set(value):
        is_occupied = value
        _refresh()

@onready var name_label: Label = %HeroName
@onready var level_label: Label = %HeroLevel
@onready var role_label: Label = %HeroRole
@onready var hp_bar: ProgressBar = %HealthBar
@onready var leader_label: Label = %LeaderMark
@onready var select_button: Button = %SelectButton

func _ready() -> void:
    _refresh()
    if not select_button.pressed.is_connected(_on_pressed):
        select_button.pressed.connect(_on_pressed)

func set_hero(data: Dictionary) -> void:
    hero_name = str(data.get("name", hero_name))
    hero_level = maxi(1, int(data.get("level", hero_level)))
    hero_role = str(data.get("role", hero_role))
    health_fraction = clampf(float(data.get("hp_ratio", health_fraction)), 0.0, 1.0)
    is_leader = bool(data.get("leader", is_leader))
    is_occupied = bool(data.get("occupied", is_occupied))
    _refresh()

func _refresh() -> void:
    if not is_node_ready():
        return
    name_label.text = hero_name if is_occupied else "Freier Platz"
    level_label.text = "Lv. %d" % hero_level if is_occupied else ""
    role_label.text = hero_role if is_occupied else ""
    hp_bar.value = health_fraction * 100.0 if is_occupied else 0.0
    hp_bar.visible = is_occupied
    leader_label.visible = is_leader and is_occupied
    select_button.disabled = not is_occupied
    select_button.tooltip_text = "Held auswählen: %s" % hero_name if is_occupied else "Kein Held"

func _on_pressed() -> void:
    hero_selected.emit(hero_index)
