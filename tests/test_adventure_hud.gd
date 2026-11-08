extends SceneTree

# Headless Godot UI smoke test: the original fantasy HUD must remain usable,
# and the existing menus must open above the adventure overlay.
func _initialize() -> void:
 call_deferred("_run_tests")

func _fail(reason: String) -> void:
 push_error("Adventure HUD: " + reason)
 quit(1)

func _run_tests() -> void:
 var packed: PackedScene = load("res://scenes/main.tscn")
 if packed == null:
  _fail("Main scene cannot load")
  return
 var game: Node = packed.instantiate()
 get_root().add_child(game)
 await process_frame
 var hud: Control = game.get_node_or_null("HUD") as Control
 if hud == null:
  _fail("HUD missing")
  return
 var overlay: Control = hud.get("adventure_overlay") as Control
 if overlay == null:
  _fail("Adventure overlay not attached to HUD")
  return
 if not overlay.visible:
  _fail("Adventure overlay unexpectedly hidden at start")
  return
 for name in ["AdventureResources", "JourneyPlaque", "AdventureTeam", "AdventureDock", "MoreAdventures"]:
  if overlay.get_node_or_null(name) == null:
   _fail("UI widget missing: " + name)
   return
 var hero_strip: Node = overlay.get_node_or_null("AdventureTeam")
 for slot in range(1, 5):
  if hero_strip.get_node_or_null("PartySlot" + str(slot)) == null:
   _fail("Hero portrait slot missing: " + str(slot))
   return
 # Each hero portrait must be a real touch target that opens the correct slot.
 var party_buttons: Array = overlay.get("party_buttons")
 if party_buttons.size() != 4:
  _fail("Exactly four interactive party cards expected")
  return
 for slot in range(4):
  var tile: Control = hero_strip.get_node_or_null("PartySlot" + str(slot + 1)) as Control
  var touch: Button = null
  if tile != null:
   touch = tile.get_node_or_null("SelectHero") as Button
  if touch == null or party_buttons[slot] != touch or touch.disabled:
   _fail("Missing enabled hero card touch target: " + str(slot + 1))
   return
  if touch.mouse_filter != Control.MOUSE_FILTER_STOP:
   _fail("Hero card does not accept touch input: " + str(slot + 1))
   return
 var class_menu: Control = hud.get_node_or_null("ClassMenu") as Control
 var team: Node3D = game.get_node_or_null("TeamFormation") as Node3D
 if class_menu == null or team == null:
  _fail("Team selection dependencies missing")
  return
 for slot in range(4):
  party_buttons[slot].emit_signal("pressed")
  await process_frame
  if not class_menu.visible or overlay.visible:
   _fail("Tapped hero did not open ClassMenu: " + str(slot + 1))
   return
  var selector: OptionButton = class_menu.get("slot_selector") as OptionButton
  var selected_class: OptionButton = class_menu.get("class_selector") as OptionButton
  if selector == null or selected_class == null or selector.selected != slot:
   _fail("Tapped hero opened incorrect slot: " + str(slot + 1))
   return
  if selected_class.selected != int(team.class_ids[slot]):
   _fail("Tapped hero showed wrong class: " + str(slot + 1))
   return
  class_menu.hide()
  await process_frame
  if not overlay.visible:
   _fail("HUD did not return after closing a selected hero")
   return
 if hud.get_node("BottomNav").visible or hud.get_node("ResourceBar").visible:
  _fail("Legacy debug navigation is still visible")
  return

 # The replacement menu must keep existing game interactions accessible.
 overlay.call("_on_navigation", "team")
 await process_frame
 if not hud.get_node("ClassMenu").visible or overlay.visible:
  _fail("Team menu was blocked by adventure overlay")
  return
 hud.get_node("ClassMenu").hide()
 await process_frame
 if not overlay.visible:
  _fail("Adventure overlay failed to return after team menu closed")
  return

 overlay.call("_on_navigation", "jewels")
 await process_frame
 var action: Control = hud.get("action_panel") as Control
 if action == null or not action.visible or overlay.visible:
  _fail("Equipment upgrade modal was blocked by overlay")
  return
 action.hide()
 await process_frame
 if not overlay.visible:
  _fail("Overlay did not return after equipment modal closed")
  return

 overlay.call("_on_navigation", "more")
 var extras: PanelContainer = overlay.get_node("MoreAdventures") as PanelContainer
 if extras == null or not extras.visible:
  _fail("More adventures drawer does not open")
  return
 overlay.call("_on_navigation", "talents")
 await process_frame
 if not hud.get_node("TalentMenu").visible or overlay.visible:
  _fail("Talent submenu was blocked by overlay")
  return
 hud.get_node("TalentMenu").hide()
 await process_frame
 if not overlay.visible:
  _fail("Overlay did not return after talent menu closed")
  return
 print("PASS: fantasy UI, hero portraits, stage map, menu navigation and modal layering")
 quit(0)
