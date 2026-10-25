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
