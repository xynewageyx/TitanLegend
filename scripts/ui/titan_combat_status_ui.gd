extends Control
## Optional mobile-friendly combat status overlay.
## Attach to a Control with two Label children named StageLabel and StateLabel.
## UI displays game state only; it does not select skills or trigger combat.
class_name TitanCombatStatusUI

@onready var stage_label: Label = get_node_or_null("StageLabel") as Label
@onready var state_label: Label = get_node_or_null("StateLabel") as Label

var _area: int = 1
var _stage: int = 1
var _wave: int = 1
var _boss: bool = false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _refresh()

func set_progress(area: int, stage: int, wave: int, is_boss: bool) -> void:
    _area = maxi(area, 1)
    _stage = clampi(stage, 1, 100)
    _wave = clampi(wave, 1, 3)
    _boss = is_boss
    _refresh()

func set_combat_state(state: String) -> void:
    if state_label != null:
        state_label.text = state

func _refresh() -> void:
    if stage_label != null:
        stage_label.text = "Gebiet %d  ·  Stage %d" % [_area, _stage]
    if state_label != null:
        state_label.text = "Bosskampf" if _boss else "Welle %d/3" % _wave
