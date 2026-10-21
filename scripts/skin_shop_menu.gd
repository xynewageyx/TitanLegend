extends Control
var panel: PanelContainer
var status_label: Label
var hero_selector: OptionButton
var skin_list: VBoxContainer
func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 panel = PanelContainer.new()
 panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
 panel.anchor_left = 0.08
 panel.anchor_right = 0.92
 panel.anchor_top = 0.14
 panel.anchor_bottom = 0.82
 panel.offset_left = 0
 panel.offset_right = 0
 panel.offset_top = 0
 panel.offset_bottom = 0
 panel.mouse_filter = Control.MOUSE_FILTER_STOP
 add_child(panel)
 var scroll := ScrollContainer.new()
 panel.add_child(scroll)
 var column := VBoxContainer.new()
 column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.add_child(column)
 var heading := Label.new()
 heading.text = "SKIN-SHOP · Kosmetik ohne Kampfbonus"
 heading.add_theme_font_size_override("font_size", 21)
 column.add_child(heading)
 status_label = Label.new()
 column.add_child(status_label)
 hero_selector = OptionButton.new()
 for i in range(4):
  hero_selector.add_item("Held " + str(i + 1))
 hero_selector.item_selected.connect(func(_index: int): _refresh())
 column.add_child(hero_selector)
 skin_list = VBoxContainer.new()
 column.add_child(skin_list)
 var close_button := Button.new()
 close_button.text = "Schließen"
 close_button.pressed.connect(hide)
 column.add_child(close_button)
 ShopManager.skins_changed.connect(_refresh)
 ShopManager.gems_changed.connect(func(_value: int): _refresh())
 hide()
func open_menu() -> void:
 show()
 _refresh()
func _refresh() -> void:
 if status_label == null:
  return
 status_label.text = "Edelsteine: " + str(ShopManager.gems) + "  ·  R" + str(GameManager.current_reincarnation_level)
 for child in skin_list.get_children():
  child.queue_free()
 var reset_button := Button.new()
 reset_button.text = "Standardskin ausrüsten"
 reset_button.pressed.connect(func(): ShopManager.equip("", hero_selector.selected))
 skin_list.add_child(reset_button)
 for key in ShopManager.CATALOG.keys():
  var skin_id: String = str(key)
  var item: Dictionary = ShopManager.CATALOG[skin_id]
  var button := Button.new()
  var owned: bool = ShopManager.unlocked_skins.has(skin_id)
  var is_premium: bool = bool(item.get("premium", false))
  var price_text: String = str(item.get("price", "")) if is_premium else str(item.get("cost", 0)) + " Edelsteine"
  button.text = str(item.get("title", skin_id)) + "\n" + ("Freigeschaltet" if owned else price_text)
  button.custom_minimum_size.y = 68
  if owned:
   button.disabled = str(item.get("kind", "")) != "hero"
   button.pressed.connect(_equip_skin.bind(skin_id))
  elif is_premium:
   button.disabled = true # Enable only when store integration is verified.
   button.tooltip_text = "Echtgeldkauf noch nicht eingerichtet"
  else:
   button.disabled = ShopManager.gems < int(item.get("cost", 0)) or GameManager.current_reincarnation_level < int(item.get("min_r", 0))
   button.pressed.connect(_buy_skin.bind(skin_id))
  skin_list.add_child(button)
func _buy_skin(skin_id: String) -> void:
 ShopManager.buy_with_gems(skin_id)
 _refresh()
func _equip_skin(skin_id: String) -> void:
 ShopManager.equip(skin_id, hero_selector.selected)
 _refresh()
