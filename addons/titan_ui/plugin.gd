@tool
extends EditorPlugin

# Optional editor helper: install by enabling the plugin in Project Settings.
# Runtime HUD remains independent of editor plugins.
func _enter_tree() -> void:
 print("Titan Legends UI toolkit enabled")
 add_autoload_singleton("TitanUITheme", "res://scripts/ui/titan_ui_theme.gd")

func _exit_tree() -> void:
 pass
