@tool
extends EditorPlugin

# Optional editor helper: install by enabling the plugin in Project Settings.
# Runtime HUD remains independent of editor plugins.
func _enter_tree() -> void:
 print("Titan Legends UI toolkit enabled")
 add_autoload_singleton("TitanUIHUD", "res://scripts/ui/titan_hud_controller.gd")

func _exit_tree() -> void:
 pass
