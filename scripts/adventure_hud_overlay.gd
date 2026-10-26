extends Control
class_name TitanAdventureHudOverlay

# Original fantasy-themed touch HUD: four hero portraits, map plaque, status,
# five prominent navigation slots and a compact overflow menu.
const SKIN = preload("res://scripts/adventure_ui_theme.gd")
const MAP_BADGE = preload("res://scripts/adventure_map_badge.gd")
const NAV_ART = preload("res://scripts/adventure_nav_icon.gd")
const NAV_ENTRIES := [
 ["⚔", "Kampf", "combat"],
 ["◆", "Helden", "jewels"],
 ["♟", "Team", "team"],
 ["✦", "Skills", "skills"],
 ["⋯", "Mehr", "more"]
]
const MORE_ENTRIES := [
 ["▣ Ausrüstung", "equipment"],
 ["✥ Talente", "talents"],
 ["✧ Reinkarnation", "reincarnation"],
 ["✦ Astralprüfung", "astral"],
 ["▣ Kostüme", "shop"]
]
const ROLE_ICONS := ["◆", "⚔", "✚"]
const ROLE_TEXT := ["TANK", "SCHADEN", "HEILUNG"]

var hud: Control
var battle: Node3D
var biome: Node3D
var gold_label: Label
var ticket_label: Label
var xp_label: Label
var stage_name: Label
var stage_detail: Label
var journey_progress: ProgressBar
var map_control: Control
var party_names: Array[Label] = []
var party_roles: Array[Label] = []
var party_icons: Array[Label] = []
var party_bars: Array[ProgressBar] = []
var party_bonus: Label
var nav_buttons: Dictionary = {}
var more_panel: PanelContainer
var more_open: bool = false
var active_page: String = "combat"

func initialize(parent_hud: Control, battle_node: Node3D, biome_node: Node3D) -> void:
 hud = parent_hud
 battle = battle_node
 biome = biome_node

func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 _build_resources()
 _build_journey()
 _build_party()
 _build_navigation()
 refresh()

func _resource_tile(parent: Container, heading: String) -> Label:
 var tile := PanelContainer.new()
 tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 tile.add_theme_stylebox_override("panel", SKIN.plaque(Color("#ffefd2f4"), SKIN.WOOD, 16, 3))
 parent.add_child(tile)
 var value := Label.new()
 value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
 SKIN.title(value, 17)
 value.text = heading
 tile.add_child(value)
 return value

func _build_resources() -> void:
 var ribbon := HBoxContainer.new()
 ribbon.name = "AdventureResources"
 ribbon.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 ribbon.offset_left = 9
 ribbon.offset_right = -9
 ribbon.offset_top = 10
 ribbon.offset_bottom = 76
 ribbon.add_theme_constant_override("separation", 8)
 ribbon.mouse_filter = Control.MOUSE_FILTER_PASS
 add_child(ribbon)
 gold_label = _resource_tile(ribbon, "GOLD")
 ticket_label = _resource_tile(ribbon, "TICKETS")
 xp_label = _resource_tile(ribbon, "LEVEL")

func _build_journey() -> void:
 var card := PanelContainer.new()
 card.name = "JourneyPlaque"
 card.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
 card.offset_left = -274
 card.offset_right = -11
 card.offset_top = 91
 card.offset_bottom = 224
 card.add_theme_stylebox_override("panel", SKIN.plaque(Color("#fff1d8f5"), SKIN.WOOD, 19, 4))
 add_child(card)
 var content := HBoxContainer.new()
 content.add_theme_constant_override("separation", 6)
 card.add_child(content)
 map_control = Control.new()
 map_control.name = "AdventureMap"
 map_control.set_script(MAP_BADGE)
 map_control.custom_minimum_size = Vector2(95, 95)
 map_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
 content.add_child(map_control)
 var text_stack := VBoxContainer.new()
 text_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 text_stack.add_theme_constant_override("separation", 4)
 content.add_child(text_stack)
 stage_name = Label.new()
 SKIN.title(stage_name, 17)
 stage_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 stage_name.text = "ABENTEUER"
 text_stack.add_child(stage_name)
 stage_detail = Label.new()
 SKIN.title(stage_detail, 16)
 stage_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 stage_detail.text = "Stufe 1\nWelle 1/10"
 text_stack.add_child(stage_detail)
 journey_progress = ProgressBar.new()
 journey_progress.custom_minimum_size.y = 14
 journey_progress.max_value = 10.0
 SKIN.small_bar(journey_progress, SKIN.GOLD)
 text_stack.add_child(journey_progress)

func _build_party() -> void:
 var strip := VBoxContainer.new()
 strip.name = "AdventureTeam"
 strip.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
 strip.offset_left = 11
 strip.offset_right = 210
 strip.offset_top = 94
 strip.offset_bottom = 404
 strip.add_theme_constant_override("separation", 5)
 add_child(strip)
 for i in range(4):
  var tile := PanelContainer.new()
  tile.name = "PartySlot" + str(i + 1)
  tile.custom_minimum_size.y = 61
  tile.add_theme_stylebox_override("panel", SKIN.plaque(Color("#fff0d7f3"), SKIN.WOOD, 15, 2))
  strip.add_child(tile)
  var line := HBoxContainer.new()
  line.add_theme_constant_override("separation", 7)
  tile.add_child(line)
  var icon_label := Label.new()
  icon_label.custom_minimum_size = Vector2(38, 42)
  icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  icon_label.add_theme_stylebox_override("normal", SKIN.plaque(SKIN.GOLD_LIGHT, SKIN.GOLD, 13, 2))
  SKIN.title(icon_label, 23)
  icon_label.text = "◆"
  line.add_child(icon_label)
  party_icons.append(icon_label)
  var column := VBoxContainer.new()
  column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  column.add_theme_constant_override("separation", 0)
  line.add_child(column)
  var name_label := Label.new()
  SKIN.title(name_label, 15)
  name_label.clip_text = true
  name_label.text = "Held " + str(i + 1)
  column.add_child(name_label)
  party_names.append(name_label)
  var role_label := Label.new()
  SKIN.title(role_label, 12)
  role_label.add_theme_color_override("font_color", SKIN.MUTED)
  role_label.text = "Teammitglied"
  column.add_child(role_label)
  party_roles.append(role_label)
  var hp := ProgressBar.new()
  hp.max_value = 100
  hp.value = 100
  hp.custom_minimum_size.y = 9
  SKIN.small_bar(hp, SKIN.GREEN)
  column.add_child(hp)
  party_bars.append(hp)
 party_bonus = Label.new()
 party_bonus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 SKIN.title(party_bonus, 13)
 strip.add_child(party_bonus)

func _nav_button(parent: Container, _icon_text: String, caption: String, key: String) -> Button:
 var b := Button.new()
 b.name = "Nav_" + key
 b.text = ""
 b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 b.custom_minimum_size.y = 88
 SKIN.button(b, key == active_page, true)
 b.pressed.connect(_on_navigation.bind(key))
 parent.add_child(b)
 # Original illustrated vector emblems replace emoji-only/debug labels.
 var contents := VBoxContainer.new()
 contents.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 contents.offset_left = 3
 contents.offset_right = -3
 contents.add_theme_constant_override("separation", 0)
 contents.mouse_filter = Control.MOUSE_FILTER_IGNORE
 b.add_child(contents)
 var artwork := Control.new()
 artwork.set_script(NAV_ART)
 artwork.set("kind", key)
 artwork.custom_minimum_size = Vector2(50, 54)
 artwork.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
 contents.add_child(artwork)
 var title := Label.new()
 title.text = caption
 title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 title.mouse_filter = Control.MOUSE_FILTER_IGNORE
 SKIN.title(title, 16)
 contents.add_child(title)
 nav_buttons[key] = b
 return b

func _build_navigation() -> void:
 # A single large-icon dock, not a two-row grid of debug controls.
 var dock := PanelContainer.new()
 dock.name = "AdventureDock"
 dock.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 dock.offset_left = 6
 dock.offset_right = -6
 dock.offset_top = -126
 dock.offset_bottom = -7
 dock.mouse_filter = Control.MOUSE_FILTER_STOP
 dock.add_theme_stylebox_override("panel", SKIN.plaque(Color("#9a653feF"), SKIN.WOOD_DARK, 20, 4))
 add_child(dock)
 var row := HBoxContainer.new()
 row.add_theme_constant_override("separation", 5)
 dock.add_child(row)
 for entry in NAV_ENTRIES:
  _nav_button(row, str(entry[0]), str(entry[1]), str(entry[2]))

 # One-tap access to every former bottom-row feature.
 more_panel = PanelContainer.new()
 more_panel.name = "MoreAdventures"
 more_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
 more_panel.offset_left = -366
 more_panel.offset_right = -10
 more_panel.offset_top = -430
 more_panel.offset_bottom = -140
 more_panel.mouse_filter = Control.MOUSE_FILTER_STOP
 more_panel.add_theme_stylebox_override("panel", SKIN.plaque(SKIN.PAPER, SKIN.WOOD, 18, 4))
 add_child(more_panel)
 var menu := GridContainer.new()
 menu.columns = 2
 menu.add_theme_constant_override("h_separation", 8)
 menu.add_theme_constant_override("v_separation", 8)
 more_panel.add_child(menu)
 for entry in MORE_ENTRIES:
  var button := Button.new()
  button.text = str(entry[0])
  button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  button.custom_minimum_size.y = 72
  SKIN.button(button, false, true)
  button.pressed.connect(_on_navigation.bind(str(entry[1])))
  menu.add_child(button)
 more_panel.hide()

func _process(_delta: float) -> void:
 if hud == null:
  return
 # Submenus are siblings created earlier by the original scene. Temporarily
 # hide this topmost overlay while one of them is open, then restore the dock.
 var modal_active: bool = false
 for menu_name in ["ClassMenu", "SkillMenu", "TalentMenu"]:
  var menu: Control = hud.get_node_or_null(menu_name) as Control
  if menu != null and menu.visible:
   modal_active = true
 var cosmetics: Variant = hud.get("skin_shop_menu")
 if cosmetics is Control and (cosmetics as Control).visible:
  modal_active = true
 var equipment_view: Variant = hud.get("equipment_panel_214")
 if equipment_view is Control and (equipment_view as Control).visible:
  modal_active = true
 var actions: Variant = hud.get("action_panel")
 if actions is Control and (actions as Control).visible:
  modal_active = true
 if modal_active and visible:
  hide()
 elif not modal_active and not visible:
  show()

func _on_navigation(target: String) -> void:
 if target == "more":
  more_open = not more_open
  more_panel.visible = more_open
  _update_nav_selection()
  return
 more_open = false
 more_panel.hide()
 active_page = target
 _update_nav_selection()
 if hud != null:
  hud.call("_open_menu", target)
  if target in ["team", "skills", "talents", "shop", "equipment"]:
   hide()

func _update_nav_selection() -> void:
 for entry in NAV_ENTRIES:
  var key: String = str(entry[2])
  var selected: bool = key == active_page or (key == "more" and more_open)
  if nav_buttons.has(key):
   SKIN.button(nav_buttons[key], selected, true)
   nav_buttons[key].add_theme_font_size_override("font_size", 19)

func refresh() -> void:
 if gold_label == null:
  return
 gold_label.text = "● " + str(GameManager.current_gold) + "\nGOLD"
 ticket_label.text = "✦ " + str(GameManager.reincarnation_tickets) + "\nTICKETS"
 xp_label.text = "Lv " + str(GameManager.character_level) + "\n" + str(GameManager.character_xp) + " XP"
 if battle == null:
  return
 var element_id: int = 0
 if biome != null:
  element_id = int(biome.current_biome)
  stage_name.text = str(biome.NAMES[clampi(element_id, 0, biome.NAMES.size() - 1)]).to_upper()
 else:
  stage_name.text = "ABENTEUER"
 stage_detail.text = "Stufe %d\nWelle %d/10" % [battle.current_level, battle.current_wave]
 journey_progress.value = clampi(battle.current_wave, 1, 10)
 map_control.call("set_progress", battle.current_wave, element_id)
 var team: Node3D = battle.team_formation
 if team == null:
  return
 for i in range(4):
  var class_id: int = clampi(int(team.class_ids[i]), 0, team.CLASS_NAMES.size() - 1)
  var role_id: int = clampi(int(team.role_ids[i]), 0, 2)
  party_names[i].text = str(team.CLASS_NAMES[class_id])
  party_roles[i].text = ROLE_TEXT[role_id]
  party_icons[i].text = ROLE_ICONS[role_id]
  var hp: int = maxi(0, int(battle.hero_hp[i]))
  var max_hp: int = maxi(1, int(battle.hero_max_hp[i]))
  party_bars[i].value = 100.0 * float(hp) / float(max_hp)
  party_bars[i].modulate = Color.WHITE if hp > 0 else Color("#a39a8e")
 var formation: bool = team.has_formation_bonus()
 party_bonus.text = "✦ FORMATIONS-BONUS" if formation else "4 HELDEN · 1 TEAM"
 party_bonus.add_theme_color_override("font_color", Color("#3a845b") if formation else SKIN.MUTED)
