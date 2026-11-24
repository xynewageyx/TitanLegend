@tool
extends EditorPlugin

# Optional editor helper: install by enabling the plugin in Project Settings.
# Runtime HUD remains independent of editor plugins.
func _enter_tree() -> void:
 add_autoload_singleton("TitanHUDManager", "res://scripts/ui/titan_hud_manager.gd")
 print("Titan Legends UI toolkit enabled")

func _exit_tree() -> void:
 pass
