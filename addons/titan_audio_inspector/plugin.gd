@tool
extends EditorPlugin

const CATALOG = preload("res://scripts/audio_event_catalog.gd")

func _enter_tree() -> void:
 add_tool_menu_item("Validate Titan Audio", _validate_audio)

func _exit_tree() -> void:
 remove_tool_menu_item("Validate Titan Audio")

func _validate_audio() -> void:
 var missing: PackedStringArray = []
 var checked: int = 0
 for event_name in CATALOG.EVENTS:
  var path: String = str(CATALOG.EVENTS[event_name])
  if not path.ends_with(".wav"):
   continue
  checked += 1
  if not ResourceLoader.exists(path):
   missing.append("%s: %s" % [event_name, path])
 if missing.is_empty():
  print("Titan Audio Inspector: %d WAV events available." % checked)
 else:
  push_warning("Titan Audio Inspector: %d/%d WAV assets missing. Generate with tools/generate_audio_sfx.py." % [missing.size(), checked])
  for item in missing:
   print("Titan Audio Inspector missing: ", item)
