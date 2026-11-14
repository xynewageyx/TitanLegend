@tool
extends EditorPlugin

# Optional editor helper: install by enabling the plugin in Project Settings.
# Runtime HUD remains independent of editor plugins.
func _enter_tree() -> void:
 print("Titan Legends UI toolkit enabled (Godot 4.7.2 Portrait HUD)")

func _exit_tree() -> void:
 pass
