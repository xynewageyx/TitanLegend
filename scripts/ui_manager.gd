extends Control
# Update 27: portrait HUD, boss HP only, tabbed local chat.
@export var battle_manager: Node3D
@export var biome_manager: Node3D
var current_tab: String = "combat"
var chat_tab: String = "Alle"
var chat_open: bool = false
var chat_lines: Array[Dictionary] = []
var last_battle_signature: String = ""
var last_gold: int = -1
var last_stage: int = -1
var offline_notice: Label
var offline_notice_until: int = 0
var last_ability_logged: String = ""
var last_ability_time: int = -99999
var chat_collapse_button: Button
var gold_label: Label
var tickets_label: Label
var xp_label: Label
var boss_panel: VBoxContainer
var boss_name: Label
var boss_hp: ProgressBar
var boss_countdown: Label
var team_status_label: Label
var chat_panel: PanelContainer
var chat_history: RichTextLabel
var chat_input: LineEdit
var chat_buttons: Dictionary = {}
var action_panel: PanelContainer
var action_title: Label
var action_detail: Label
var action_button: Button
var astral_shop_button: Button
var weapon_hero_slot: int = 0
var loot_selected_index: int = 0
var loot_select_button: Button
var loot_equip_button: Button
var loot_compare_label: Label
var loot_sell_button: Button
var loot_transfer_confirmation: ConfirmationDialog
var pending_loot_equip_id: int = -1
var pending_loot_equip_hero: int = -1
var loot_sale_confirmation: ConfirmationDialog
var pending_loot_sale_id: int = -1
var weapon_upgrade_button: Button
var weapon_rarity_button: Button
var weapon_hero_button: Button
var hardening_field: int = 0
var hardening_select_button: Button
var hardening_upgrade_button: Button
var attribute_select_index: int = 0
var attribute_select_button: Button
var attribute_apply_button: Button
var attribute_reroll_button: Button
var skin_shop_menu: Control

func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_PASS
 # Hide the obsolete scene HUD. Keep it in the scene for backwards compatibility.
 $Margin.hide()
 _make_hud()
 skin_shop_menu = Control.new()
 skin_shop_menu.set_script(load("res://scripts/skin_shop_menu.gd"))
 add_child(skin_shop_menu)
 GameManager.gold_changed.connect(_refresh)
 GameManager.xp_changed.connect(_refresh)
 GameManager.character_level_changed.connect(_refresh)
 GameManager.tickets_changed.connect(_refresh)
 GameManager.reincarnation_performed.connect(_refresh)
 GameManager.jewel_upgraded.connect(_refresh)
 GameManager.equipment_upgraded.connect(_on_equipment_upgraded)
 GameManager.loot_changed.connect(_refresh_loot)
 SaveManager.offline_rewards_received.connect(_on_offline_rewards_received)
 if battle_manager != null:
  battle_manager.battle_status_changed.connect(_on_battle_update)
 _append("System", "Willkommen bei Titan Legends!")
 if SaveManager.last_offline_gold > 0 or SaveManager.last_offline_xp > 0:
  _on_offline_rewards_received(
   SaveManager.last_offline_gold, SaveManager.last_offline_seconds,
   SaveManager.last_offline_xp, SaveManager.last_offline_levels
  )
 _refresh()

func _process(_delta: float) -> void:
 if offline_notice != null and offline_notice.visible and Time.get_ticks_msec() >= offline_notice_until:
  offline_notice.hide()
 # Refresh only the clock each frame; the rest of the HUD remains event-driven.
 if battle_manager == null or boss_countdown == null:
  return
 # Keep the wipe announcement on screen during the two-second defeat pause.
 var defeated: bool = battle_manager.is_boss and not battle_manager.battle_active and battle_manager.defeat_reason != ""
 var showing: bool = battle_manager.is_boss and (battle_manager.battle_active or defeated)
 boss_countdown.visible = showing
 if not showing:
  return
 if defeated:
  boss_countdown.text = "VERNICHTUNGSSCHLAG! TEAM BESIEGT" if battle_manager.defeat_reason == "boss_finisher" else "TEAM BESIEGT – NEUER VERSUCH"
  boss_countdown.add_theme_color_override("font_color", Color(1.0, 0.16, 0.13))
  return
 var seconds: int = ceili(battle_manager.boss_time_remaining)
 boss_countdown.text = "Boss-Zeit: %02d:%02d" % [floori(float(seconds) / 60.0), seconds % 60]
 var tint: Color = Color(1.0, 0.32, 0.27) if seconds <= 10 else (Color(1.0, 0.76, 0.29) if seconds <= 20 else Color(0.95, 0.94, 0.87))
 if seconds <= 10:
  tint.a = 0.65 + 0.35 * absf(sin(Time.get_ticks_msec() * 0.009))
 boss_countdown.add_theme_color_override("font_color", tint)

func _style(color: Color, radius: int = 14) -> StyleBoxFlat:
 var b := StyleBoxFlat.new()
 b.bg_color = color
 b.set_corner_radius_all(radius)
 return b

func _font(label: Label, px: int) -> void:
 label.add_theme_font_size_override("font_size", px)
 label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _make_button(text_value: String, parent: Node, callback: Callable, px: int = 17) -> Button:
 var b := Button.new()
 b.text = text_value
 b.custom_minimum_size.y = 46
 b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 b.add_theme_font_size_override("font_size", px)
 parent.add_child(b)
 b.pressed.connect(callback)
 return b

func _make_hud() -> void:
 # Resource bar at top.
 var resources := HBoxContainer.new()
 resources.name = "ResourceBar"
 resources.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 resources.offset_left = 12
 resources.offset_right = -12
 resources.offset_top = 12
 resources.offset_bottom = 64
 resources.add_theme_constant_override("separation", 12)
 add_child(resources)
 for key in ["Gold", "Tickets", "XP"]:
  var p := PanelContainer.new()
  p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  p.add_theme_stylebox_override("panel", _style(Color(0.02, 0.045, 0.07, 0.88), 18))
  resources.add_child(p)
  var l := Label.new()
  l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  _font(l, 17 if key == "XP" else 19)
  p.add_child(l)
  if key == "Gold": gold_label = l
  elif key == "Tickets": tickets_label = l
  else: xp_label = l

 # Boss-only display. Hidden for normal mobs.
 boss_panel = VBoxContainer.new()
 boss_panel.name = "BossHP"
 boss_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 boss_panel.offset_left = 32
 boss_panel.offset_right = -32
 boss_panel.offset_top = 85
 boss_panel.offset_bottom = 195
 add_child(boss_panel)
 boss_name = Label.new()
 boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 _font(boss_name, 23)
 boss_panel.add_child(boss_name)
 boss_hp = ProgressBar.new()
 boss_hp.custom_minimum_size.y = 24
 boss_hp.max_value = 100
 boss_hp.show_percentage = true
 boss_hp.add_theme_stylebox_override("background", _style(Color(0.14, 0.035, 0.035, 0.93), 8))
 boss_hp.add_theme_stylebox_override("fill", _style(Color(0.92, 0.13, 0.09, 1.0), 8))
 boss_hp.add_theme_font_size_override("font_size", 18)
 boss_panel.add_child(boss_hp)
 boss_countdown = Label.new()
 boss_countdown.name = "BossCountdown"
 boss_countdown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 _font(boss_countdown, 22)
 boss_countdown.add_theme_color_override("font_color", Color(0.95, 0.94, 0.87))
 boss_panel.add_child(boss_countdown)
 boss_panel.hide()
 # A compact status indicator stays visible below the boss bar while debuffed.
 team_status_label = Label.new()
 team_status_label.name = "TeamElementStatus"
 team_status_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 team_status_label.offset_left = 30
 team_status_label.offset_right = -30
 team_status_label.offset_top = 202
 team_status_label.offset_bottom = 236
 team_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 team_status_label.add_theme_font_size_override("font_size", 16)
 team_status_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.36))
 team_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(team_status_label)
 team_status_label.hide()

 # Update 29: readable 4+3 icon navigation for narrow portrait screens.
 # Bottom nav anchored to portrait viewport.
 var nav := PanelContainer.new()
 nav.name = "BottomNav"
 nav.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 nav.offset_left = 6
 nav.offset_right = -6
 nav.offset_top = -170
 nav.offset_bottom = -8
 nav.add_theme_stylebox_override("panel", _style(Color(0.015, 0.025, 0.04, 0.93)))
 add_child(nav)
 var grid := GridContainer.new()
 grid.columns = 4
 grid.add_theme_constant_override("h_separation", 5)
 grid.add_theme_constant_override("v_separation", 4)
 nav.add_child(grid)
 for entry in [["⚔\nKampf", "combat"], ["◆\nJuwelen", "jewels"], ["✦\nReink.", "reincarnation"], ["▣\nShop", "shop"], ["♟\nTeam", "team"], ["✧\nSkills", "skills"], ["✥\nTalente", "talents"], ["✧\nAstral", "astral"]]:
  var target: String = entry[1]
  var button := _make_button(entry[0], grid, _open_menu.bind(target), 17)
  button.add_theme_stylebox_override("normal", _style(Color(0.045, 0.085, 0.13, 0.98), 12))
  button.add_theme_stylebox_override("hover", _style(Color(0.08, 0.22, 0.32, 0.98), 12))
  button.add_theme_stylebox_override("pressed", _style(Color(0.07, 0.34, 0.48, 0.98), 12))
  button.clip_text = true
  button.custom_minimum_size.y = 70

 # Chat occupies lower section but can be collapsed to see more of the battle.
 chat_panel = PanelContainer.new()
 chat_panel.name = "ChatPanel"
 chat_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 chat_panel.offset_left = 12
 chat_panel.offset_right = -12
 chat_panel.offset_top = -245
 chat_panel.offset_bottom = -184
 chat_panel.add_theme_stylebox_override("panel", _style(Color(0.012, 0.025, 0.04, 0.88)))
 add_child(chat_panel)
 var chat_box := VBoxContainer.new()
 chat_box.add_theme_constant_override("separation", 5)
 chat_panel.add_child(chat_box)
 var tabs := HBoxContainer.new()
 chat_box.add_child(tabs)
 for tab_name in ["Alle", "Welt", "Team", "Gilde", "System"]:
  var b := _make_button(tab_name, tabs, _select_chat.bind(tab_name), 17)
  b.clip_text = true
  b.add_theme_stylebox_override("normal", _style(Color(0.045, 0.085, 0.13, 0.98), 9))
  chat_buttons[tab_name] = b
 chat_collapse_button = _make_button("−", tabs, _toggle_chat, 18)
 chat_collapse_button.size_flags_horizontal = Control.SIZE_SHRINK_END
 chat_collapse_button.custom_minimum_size.x = 40
 chat_history = RichTextLabel.new()
 chat_history.bbcode_enabled = true
 chat_history.scroll_following = true
 chat_history.size_flags_vertical = Control.SIZE_EXPAND_FILL
 chat_history.mouse_filter = Control.MOUSE_FILTER_STOP
 chat_history.add_theme_font_size_override("normal_font_size", 19)
 chat_box.add_child(chat_history)
 var input_row := HBoxContainer.new()
 chat_box.add_child(input_row)
 chat_input = LineEdit.new()
 chat_input.placeholder_text = "Lokale Notiz eingeben …"
 chat_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 chat_input.text_submitted.connect(_submit_chat)
 input_row.add_child(chat_input)
 _make_button("➤", input_row, _send_chat, 19).custom_minimum_size.x = 52
 # Do not let an Android keyboard obscure the chat input.
 chat_input.caret_blink = true

 # Small modal for existing jewel/reincarnation/shop controls.
 action_panel = PanelContainer.new()
 action_panel.name = "ActionPanel"
 action_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
 action_panel.custom_minimum_size = Vector2(0, 260)
 action_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
 action_panel.anchor_left = 0.08
 action_panel.anchor_right = 0.92
 action_panel.offset_left = 0
 action_panel.offset_right = 0
 action_panel.offset_top = 200
 action_panel.offset_bottom = 790
 action_panel.add_theme_stylebox_override("panel", _style(Color(0.025, 0.045, 0.065, 0.97)))
 add_child(action_panel)
 # Many upgrade buttons must remain accessible on portrait Android screens.
 var action_scroll := ScrollContainer.new()
 action_scroll.custom_minimum_size.y = 0
 action_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 action_panel.add_child(action_scroll)
 var modal := VBoxContainer.new()
 modal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 modal.add_theme_constant_override("separation", 10)
 action_scroll.add_child(modal)
 action_title = Label.new()
 _font(action_title, 24)
 action_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 modal.add_child(action_title)
 action_detail = Label.new()
 _font(action_detail, 19)
 action_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 modal.add_child(action_detail)
 action_button = _make_button("Ausführen", modal, _on_action_pressed, 19)
 weapon_hero_button = _make_button("Held wechseln", modal, _next_weapon_hero, 17)
 weapon_upgrade_button = _make_button("Waffe verbessern", modal, _upgrade_current_weapon, 17)
 weapon_rarity_button = _make_button("Qualitaet verbessern", modal, _upgrade_current_weapon_rarity, 17)
 loot_select_button = _make_button("Loot ansehen", modal, _next_loot_item, 17)
 loot_equip_button = _make_button("Loot ausruesten", modal, _equip_selected_loot, 17)
 loot_transfer_confirmation = ConfirmationDialog.new()
 loot_transfer_confirmation.title = "Ausrüstung übertragen?"
 loot_transfer_confirmation.confirmed.connect(_confirm_loot_transfer)
 loot_transfer_confirmation.canceled.connect(_cancel_loot_transfer)
 add_child(loot_transfer_confirmation)
 loot_compare_label = Label.new()
 loot_compare_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 loot_compare_label.add_theme_font_size_override("font_size", 17)
 modal.add_child(loot_compare_label)
 loot_sell_button = _make_button("Gegenstand verkaufen", modal, _sell_selected_loot, 17)
 loot_sale_confirmation = ConfirmationDialog.new()
 loot_sale_confirmation.title = "Gegenstand verkaufen?"
 loot_sale_confirmation.confirmed.connect(_confirm_loot_sale)
 loot_sale_confirmation.canceled.connect(_cancel_loot_sale)
 add_child(loot_sale_confirmation)
 hardening_select_button = _make_button("Haertungsfeld wechseln", modal, _next_hardening_field, 17)
 hardening_upgrade_button = _make_button("Haerten", modal, _upgrade_current_hardening, 17)
 attribute_select_button = _make_button("Attribut waehlen", modal, _next_hardening_attribute, 17)
 attribute_apply_button = _make_button("Attribut setzen", modal, _apply_hardening_attribute, 17)
 attribute_reroll_button = _make_button("Zufaellig neu", modal, _reroll_hardening_attribute, 17)
 astral_shop_button = _make_button("Astralshop: 30 Marken → 10 Tickets", modal, _buy_astral_reward, 17)
 astral_shop_button.hide()
 _make_button("Schließen", modal, func(): action_panel.hide(), 18)
 action_panel.hide()
 # Kurz sichtbare Info beim erneuten Start nach laengerer Abwesenheit.
 offline_notice = Label.new()
 offline_notice.name = "OfflineGoldNotice"
 offline_notice.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 offline_notice.offset_left = 24
 offline_notice.offset_right = -24
 offline_notice.offset_top = -311
 offline_notice.offset_bottom = -261
 offline_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 offline_notice.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
 offline_notice.add_theme_font_size_override("font_size", 21)
 offline_notice.add_theme_color_override("font_color", Color("#f9dc7a"))
 offline_notice.add_theme_stylebox_override("normal", _style(Color(0.025, 0.045, 0.065, 0.94), 12))
 offline_notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(offline_notice)
 offline_notice.hide()
 _select_chat("Alle")
 _apply_chat_visibility()

func _open_menu(target: String) -> void:
 if target == "shop":
  skin_shop_menu.open_menu()
  return
 if target == "team":
  $ClassMenu.open_menu()
  return
 if target == "skills":
  $SkillMenu.open_menu()
  return
 if target == "talents":
  $TalentMenu.open_menu()
  return
 current_tab = target
 if target == "combat":
  action_panel.hide()
 else:
  action_panel.show()
  _refresh()

func _toggle_chat() -> void:
 chat_open = not chat_open
 _apply_chat_visibility()

func _apply_chat_visibility() -> void:
 chat_panel.offset_top = -490 if chat_open else -245
 chat_panel.offset_bottom = -184
 chat_history.visible = chat_open
 chat_input.get_parent().visible = chat_open
 chat_collapse_button.text = "−" if chat_open else "+"

func _select_chat(tab_name: String) -> void:
 chat_tab = tab_name
 for channel_name in chat_buttons:
  chat_buttons[channel_name].disabled = channel_name == tab_name
 _render_chat()
 chat_input.placeholder_text = "Lokale Notiz (kein Online-Chat)"

func _append(channel: String, message: String) -> void:
 chat_lines.append({"channel": channel, "message": message, "time": Time.get_time_string_from_system().substr(0, 5)})
 if chat_lines.size() > 120:
  chat_lines.pop_front()
 if chat_history != null:
  _render_chat()

func _render_chat() -> void:
 if chat_history == null: return
 chat_history.clear()
 var palette := {"System": "#ffb36b", "Welt": "#f5d37a", "Team": "#70ccff", "Gilde": "#79e89a"}
 for item in chat_lines:
  var channel: String = item["channel"]
  if chat_tab != "Alle" and chat_tab != channel: continue
  var safe_message: String = str(item["message"]).replace("[", "(").replace("]", ")")
  var color: String = palette.get(channel, "#ffffff")
  chat_history.append_text("[color=#a0aab8][" + item["time"] + "] [/color][color=" + color + "][" + channel + "][/color] " + safe_message + "\n")

func _submit_chat(message: String) -> void:
 if message.strip_edges().is_empty(): return
 # No network transport exists: messages are explicitly local notes.
 _append("System", "[Lokale Notiz] " + message.strip_edges().substr(0, 150))
 chat_input.clear()

func _send_chat() -> void:
 _submit_chat(chat_input.text)

func _on_offline_rewards_received(gold: int, seconds: int, xp: int, levels: int) -> void:
 if gold <= 0 and xp <= 0:
  return
 var hours: int = int(seconds / 3600)
 var minutes: int = int(seconds / 60) % 60
 var text_value := "Offline: +" + str(gold) + " Gold | +" + str(xp) + " XP"
 var level_text := " | +" + str(levels) + " Level" if levels > 0 else ""
 _append("System", text_value + level_text + " (" + str(hours) + " Std " + str(minutes) + " Min) – keine Offline-Bosskaempfe.")
 if offline_notice != null:
  offline_notice.text = text_value
  offline_notice.show()
  offline_notice_until = Time.get_ticks_msec() + 9000
 _refresh()

func _on_battle_update() -> void:
 if battle_manager == null: return
 var signature := str(battle_manager.current_level) + ":" + str(battle_manager.current_wave)
 if signature != last_battle_signature:
  last_battle_signature = signature
  last_ability_logged = ""
  _append("System", "Stage " + str(battle_manager.current_level) + " – Welle " + str(battle_manager.current_wave) + "/10")
 var ability: String = str(battle_manager.last_ability)
 if ability != "" and ability != "Standardangriff":
  var now: int = Time.get_ticks_msec()
  # Log ability changes, or the same ability at most once per 8 seconds.
  if ability != last_ability_logged or now - last_ability_time >= 8000:
   _append("System", "Fähigkeit: " + ability)
   last_ability_logged = ability
   last_ability_time = now
 _refresh()

func _refresh(_unused: int = 0) -> void:
 gold_label.text = "🟡 " + str(GameManager.current_gold)
 tickets_label.text = "Tickets: " + str(GameManager.reincarnation_tickets)
 xp_label.text = "Lv " + str(GameManager.character_level) + "\n" + str(GameManager.character_xp) + "/" + str(GameManager.xp_for_next_level()) + " XP"
 if last_gold >= 0 and GameManager.current_gold > last_gold:
  _append("System", "+" + str(GameManager.current_gold - last_gold) + " Gold erhalten")
 last_gold = GameManager.current_gold
 if battle_manager != null:
  if team_status_label != null:
   var active_status: bool = battle_manager.team_element_status >= 0 and battle_manager.skill_tick <= battle_manager.team_status_until_tick and battle_manager.battle_active
   var team_defeated: bool = battle_manager.defeat_reason != "" and not battle_manager.battle_active
   team_status_label.visible = active_status or (team_defeated and not battle_manager.is_boss)
   if team_defeated and not battle_manager.is_boss:
    team_status_label.text = "TEAM BESIEGT – NEUER VERSUCH"
   elif active_status:
    var remaining_ticks: int = maxi(0, battle_manager.team_status_until_tick - battle_manager.skill_tick)
    team_status_label.text = "✦ " + TitanElementDebuffs.status_name(battle_manager.team_element_status) + "  ·  " + str(remaining_ticks) + " Ticks"
  boss_panel.visible = battle_manager.is_boss
  if battle_manager.is_boss:
   var element_name: String = "Titan"
   if biome_manager != null:
    element_name = str(biome_manager.NAMES[biome_manager.current_biome])
   boss_name.text = ("FUSIONSTITAN – " if battle_manager.is_fusion_boss else "") + element_name + "-" + battle_manager.boss_title
   if battle_manager.boss_cast_ticks > 0:
    boss_name.text = "⚠ " + battle_manager.boss_cast_name + (" | CC %d/%d" % [battle_manager.boss_cc_progress, battle_manager.boss_cc_required] if battle_manager.boss_cc_required > 0 else " | Kein Pflicht-CC")
   elif battle_manager.boss_interrupt_message != "":
    boss_name.text = "✓ " + battle_manager.boss_interrupt_message
   if battle_manager.boss_minion_max_hp > 0:
    var alive: int = 0
    for value in battle_manager.boss_minion_hp:
     if value > 0:
      alive += 1
    boss_name.text += " | Begleiter %d/2" % alive
    if battle_manager.boss_buff_active:
     boss_name.text += " | Phase 2: " + battle_manager.boss_buff_kind
   boss_hp.value = 100.0 * float(battle_manager.enemy_hp) / float(maxi(1, battle_manager.enemy_max_hp))
 action_button.disabled = false
 astral_shop_button.visible = current_tab == "astral"
 weapon_hero_button.visible = current_tab == "jewels"
 weapon_upgrade_button.visible = current_tab == "jewels"
 weapon_rarity_button.visible = current_tab == "jewels"
 loot_select_button.visible = current_tab == "jewels"
 loot_equip_button.visible = current_tab == "jewels"
 loot_compare_label.visible = current_tab == "jewels"
 loot_sell_button.visible = current_tab == "jewels"
 hardening_select_button.visible = current_tab == "jewels"
 hardening_upgrade_button.visible = current_tab == "jewels"
 attribute_select_button.visible = current_tab == "jewels"
 attribute_apply_button.visible = current_tab == "jewels"
 attribute_reroll_button.visible = current_tab == "jewels"
 if current_tab == "jewels":
  weapon_hero_button.text = "Waffe Held %d / 4 wechseln" % (weapon_hero_slot + 1)
  var weapon_level: int = GameManager.weapon_levels[weapon_hero_slot]
  var weapon_cost: int = GameManager.weapon_upgrade_cost(weapon_hero_slot)
  weapon_upgrade_button.text = "Waffe %d → %d | %d Gold" % [weapon_level, weapon_level + 1, weapon_cost] if weapon_cost > 0 else "Waffe MAX"
  weapon_upgrade_button.disabled = weapon_cost <= 0 or GameManager.current_gold < weapon_cost
  if GameManager.equipment_inventory.is_empty():
   loot_select_button.text = "Inventar: leer (Boss-Drops)"
   loot_equip_button.text = "Kein Gegenstand vorhanden"
   loot_equip_button.disabled = true
   loot_compare_label.text = "Kein Gegenstand zum Vergleichen."
   loot_sell_button.disabled = true
   loot_sell_button.text = "Nichts verkaufen"
  else:
   loot_selected_index = posmod(loot_selected_index, GameManager.equipment_inventory.size())
   var selected_loot: Dictionary = GameManager.equipment_inventory[loot_selected_index]
   loot_select_button.text = "Inventar %d/%d: %s" % [loot_selected_index + 1, GameManager.equipment_inventory.size(), GameManager.loot_item_name(selected_loot)]
   loot_equip_button.text = "Held %d ausruesten: %s" % [weapon_hero_slot + 1, GameManager.LOOT_SLOTS[int(selected_loot["slot"])]]
   loot_equip_button.disabled = int(GameManager.equipped_loot[weapon_hero_slot][int(selected_loot["slot"])]) == int(selected_loot["id"])
   var comparison: Dictionary = GameManager.compare_loot(weapon_hero_slot, int(selected_loot["id"]))
   var difference: float = float(comparison["difference"])
   var verdict: String = "BESSER" if difference > 0.000001 else ("SCHWAECHER" if difference < -0.000001 else "GLEICH STARK")
   var worn_by: int = GameManager.loot_equipped_hero(int(selected_loot["id"]))
   var ownership: String = "Im Inventar" if worn_by < 0 else "Angelegt bei Held %d" % (worn_by + 1)
   loot_compare_label.text = "%s | %s\\nAktuell: %s (+%.2f%%)\\nAusgewaehlt: +%.2f%%\\n%s: %+.2f Prozentpunkte" % [comparison["slot_name"], ownership, comparison["equipped_name"], 100.0 * float(comparison["equipped"]), 100.0 * float(comparison["candidate"]), verdict, 100.0 * difference]
   if worn_by >= 0 and worn_by != weapon_hero_slot:
    loot_compare_label.text += "\\nACHTUNG: Held %d verliert diesen Gegenstand bei Übertragung." % (worn_by + 1)
   var equipped: bool = GameManager.is_loot_equipped(int(selected_loot["id"]))
   loot_sell_button.text = "Angelegten Gegenstand nicht verkaufen" if equipped else "Verkaufen: %d Gold" % GameManager.loot_sale_price(selected_loot)
   loot_sell_button.disabled = equipped
  var weapon_rarity: int = GameManager.weapon_rarities[weapon_hero_slot]
  var rarity_cost: int = GameManager.weapon_rarity_upgrade_cost(weapon_hero_slot)
  var rarity_text: String = GameManager.WEAPON_RARITIES[weapon_rarity]
  if weapon_rarity >= GameManager.WEAPON_RARITIES.size() - 1:
   weapon_rarity_button.text = "Qualitaet Lila – MAX"
  elif rarity_cost <= 0:
   weapon_rarity_button.text = "%s → %s ab Waffenlevel %d" % [rarity_text, GameManager.WEAPON_RARITIES[weapon_rarity + 1], GameManager.WEAPON_RARITY_LEVELS[weapon_rarity + 1]]
  else:
   weapon_rarity_button.text = "%s → %s: %d Gold" % [rarity_text, GameManager.WEAPON_RARITIES[weapon_rarity + 1], rarity_cost]
  weapon_rarity_button.disabled = rarity_cost <= 0 or GameManager.current_gold < rarity_cost
  var hardening_level: int = int(GameManager.hardening_levels[weapon_hero_slot][hardening_field])
  var hardening_cost: int = GameManager.hardening_upgrade_cost(weapon_hero_slot, hardening_field)
  var assigned_attribute: int = int(GameManager.hardening_attributes[weapon_hero_slot][hardening_field])
  var reroll_cost: int = GameManager.hardening_reroll_cost(weapon_hero_slot, hardening_field)
  hardening_select_button.text = "Feld %d: %s (Rang %d)" % [hardening_field + 1, GameManager.HARDENING_NAMES[assigned_attribute], hardening_level]
  attribute_select_button.text = "Waehlen: " + str(GameManager.HARDENING_NAMES[attribute_select_index])
  attribute_apply_button.text = "Attribut setzen: %d Gold" % reroll_cost
  attribute_apply_button.disabled = assigned_attribute == attribute_select_index or GameManager.current_gold < reroll_cost
  attribute_reroll_button.text = "Zufall: %d Gold" % reroll_cost
  attribute_reroll_button.disabled = GameManager.current_gold < reroll_cost
  hardening_upgrade_button.text = "Haerten %d Gold" % hardening_cost if hardening_cost > 0 else "Haertung am Level-Limit"
  hardening_upgrade_button.disabled = hardening_cost <= 0 or GameManager.current_gold < hardening_cost
 if current_tab == "astral" and battle_manager != null:
  astral_shop_button.disabled = battle_manager.astral_marks < 30
 match current_tab:
  "jewels":
   action_title.text = "Juwelen"
   action_detail.text = "Stufe " + str(GameManager.jewel_level) + " | Kosten: " + str(GameManager.jewel_level * 250) + " Gold"
   action_button.text = "Juwel verbessern"
  "reincarnation":
   action_title.text = "Reinkarnation R" + str(GameManager.current_reincarnation_level) + "/5"
   action_detail.text = "Kosten: " + str(GameManager.get_next_reincarnation_cost()) + " Tickets"
   action_button.text = "Reinkarnation starten"
   action_button.disabled = GameManager.current_reincarnation_level >= 5
  "astral":
   action_title.text = "Astralprüfung"
   if battle_manager != null:
    action_detail.text = ("Prüfung aktiv" if battle_manager.astral_active else "Prüfung bereit") + "\nEbene: " + str(battle_manager.astral_floor) + "\nAstralmarken: " + str(battle_manager.astral_marks) + "\nSiege bringen Astralmarken.\n30 Marken = 10 Tickets im Astralshop."
    action_button.text = "Zur Welt zurück" if battle_manager.astral_active else "Prüfung betreten"
  "shop":
   action_title.text = "Shop"
   action_detail.text = "Werbung: " + str(AdManager.get_remaining_ads()) + "/3\nAdMob-Plugin nicht installiert"
   action_button.text = "Werbung nicht verfügbar"
   action_button.disabled = true

func _next_weapon_hero() -> void:
 weapon_hero_slot = (weapon_hero_slot + 1) % 4
 _refresh()

func _upgrade_current_weapon() -> void:
 if GameManager.upgrade_weapon(weapon_hero_slot):
  _append("System", "Waffe Held %d verbessert" % (weapon_hero_slot + 1))
 _refresh()

func _upgrade_current_weapon_rarity() -> void:
 if GameManager.upgrade_weapon_rarity(weapon_hero_slot):
  _append("System", "Waffenqualitaet fuer Held %d verbessert" % (weapon_hero_slot + 1))
 _refresh()

func _refresh_loot() -> void:
 _refresh()

func _next_loot_item() -> void:
 if not GameManager.equipment_inventory.is_empty():
  loot_selected_index = (loot_selected_index + 1) % GameManager.equipment_inventory.size()
 _refresh()

func _equip_selected_loot() -> void:
 if GameManager.equipment_inventory.is_empty():
  return
 loot_selected_index = posmod(loot_selected_index, GameManager.equipment_inventory.size())
 var item: Dictionary = GameManager.equipment_inventory[loot_selected_index]
 var item_id: int = int(item.get("id", -1))
 var worn_by: int = GameManager.loot_equipped_hero(item_id)
 if worn_by >= 0 and worn_by != weapon_hero_slot:
  pending_loot_equip_id = item_id
  pending_loot_equip_hero = weapon_hero_slot
  loot_transfer_confirmation.dialog_text = "%s von Held %d auf Held %d übertragen?\\nHeld %d verliert damit diesen Gegenstand." % [GameManager.loot_item_name(item), worn_by + 1, weapon_hero_slot + 1, worn_by + 1]
  loot_transfer_confirmation.popup_centered()
  return
 if GameManager.equip_loot(weapon_hero_slot, item_id):
  _append("System", "Gegenstand ausgeruestet: " + GameManager.loot_item_name(item))
 _refresh()

func _cancel_loot_transfer() -> void:
 pending_loot_equip_id = -1
 pending_loot_equip_hero = -1

func _confirm_loot_transfer() -> void:
 var item_id: int = pending_loot_equip_id
 var hero: int = pending_loot_equip_hero
 _cancel_loot_transfer()
 if hero < 0 or hero >= 4:
  return
 var item: Dictionary = GameManager.loot_item_by_id(item_id)
 if item.is_empty():
  _refresh()
  return
 var worn_by: int = GameManager.loot_equipped_hero(item_id)
 if worn_by < 0 or worn_by == hero:
  # State changed after the dialog opened; do not silently transfer.
  _refresh()
  return
 if GameManager.equip_loot(hero, item_id):
  _append("System", "%s von Held %d zu Held %d übertragen" % [GameManager.loot_item_name(item), worn_by + 1, hero + 1])
 _refresh()

func _sell_selected_loot() -> void:
 if GameManager.equipment_inventory.is_empty():
  return
 loot_selected_index = posmod(loot_selected_index, GameManager.equipment_inventory.size())
 var item: Dictionary = GameManager.equipment_inventory[loot_selected_index]
 var item_id: int = int(item.get("id", -1))
 if GameManager.is_loot_equipped(item_id):
  return
 pending_loot_sale_id = item_id
 loot_sale_confirmation.dialog_text = "%s wirklich für %d Gold verkaufen?\\nDiese Aktion kann nicht rückgängig gemacht werden." % [GameManager.loot_item_name(item), GameManager.loot_sale_price(item)]
 loot_sale_confirmation.popup_centered()

func _cancel_loot_sale() -> void:
 pending_loot_sale_id = -1

func _confirm_loot_sale() -> void:
 var item_id: int = pending_loot_sale_id
 pending_loot_sale_id = -1
 if item_id <= 0:
  return
 var item: Dictionary = GameManager.loot_item_by_id(item_id)
 if item.is_empty() or GameManager.is_loot_equipped(item_id):
  _refresh()
  return
 var sale_price: int = GameManager.loot_sale_price(item)
 if GameManager.sell_loot(item_id):
  _append("System", "%s verkauft: +%d Gold" % [GameManager.loot_item_name(item), sale_price])
  loot_selected_index = 0 if GameManager.equipment_inventory.is_empty() else mini(loot_selected_index, GameManager.equipment_inventory.size() - 1)
 _refresh()

func _next_hardening_field() -> void:
 hardening_field = (hardening_field + 1) % 4
 _refresh()

func _upgrade_current_hardening() -> void:
 if GameManager.upgrade_hardening(weapon_hero_slot, hardening_field):
  _append("System", "Haertung fuer Held %d verbessert" % (weapon_hero_slot + 1))
 _refresh()

func _next_hardening_attribute() -> void:
 attribute_select_index = (attribute_select_index + 1) % GameManager.HARDENING_NAMES.size()
 _refresh()

func _apply_hardening_attribute() -> void:
 if GameManager.select_hardening_attribute(weapon_hero_slot, hardening_field, attribute_select_index):
  _append("System", "Haertungsattribut geaendert")
 _refresh()

func _reroll_hardening_attribute() -> void:
 if GameManager.reroll_hardening_attribute(weapon_hero_slot, hardening_field):
  _append("System", "Haertungsattribut neu gewuerfelt")
 _refresh()

func _on_equipment_upgraded(_slot: int, _level: int) -> void:
 _refresh()

func _on_action_pressed() -> void:
 match current_tab:
  "jewels": GameManager.upgrade_jewel()
  "reincarnation": GameManager.try_perform_reincarnation()
  "astral":
   if battle_manager != null:
    if battle_manager.astral_active: battle_manager.leave_astral()
    else: battle_manager.enter_astral()
 _refresh()

func _buy_astral_reward() -> void:
 if battle_manager != null:
  battle_manager.buy_astral_reward()
 _refresh()
