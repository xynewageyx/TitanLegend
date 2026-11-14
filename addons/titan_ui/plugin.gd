@tool
extends EditorPlugin

# Optional editor helper: install by enabling the plugin in Project Settings.
# Runtime HUD remains independent of editor plugins.
func _enter_tree() -> void:
 print("Titan Legends UI toolkit enabled")
 add_autoload_singleton("TitanUIManager", "res://addons/titan_ui/titan_ui_manager.gd")

func _exit_tree() -> void:
 pass
