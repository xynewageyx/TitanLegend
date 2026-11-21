@tool
extends EditorPlugin

# Optional editor helper: install by enabling the plugin in Project Settings.
# Runtime HUD remains independent of editor plugins.
func _enter_tree() -> void:
 print("Titan Legends UI toolkit enabled (Portrait Mode Optimized)")

func _exit_tree() -> void:
 pass
