extends Node3D
## Visual-only rig for the EXISTING four-hero formation.
## Shares the original Titan Legends 18-bone prototype, not imported/copyrighted assets.
## The rig has no meshes: existing combat art, buffs, loot and damage remain untouched.
const BUILDER = preload("res://scripts/character/titan_humanoid_rig_builder.gd")
const ANIMATION = preload("res://scripts/character/titan_modular_rig_animation.gd")

var skeleton: Skeleton3D
var player: AnimationPlayer
var defeated: bool = false

func _ready() -> void:
    skeleton = Skeleton3D.new()
    skeleton.name = "Skeleton3D"
    add_child(skeleton)
    var builder: Node3D = BUILDER.new()
    var built: bool = bool(builder.build_rig(skeleton))
    builder.free()
    if not built:
        push_error("Titan live-formation rig could not be initialized")
        return
    player = AnimationPlayer.new()
    player.name = "TitanAnimations"
    player.set_script(ANIMATION)
    skeleton.add_child(player)
    if not bool(player.call("setup_rig", skeleton)):
        push_error("Titan live-formation rig motions could not be created")
        return
    player.animation_finished.connect(_on_animation_finished)
    play_motion("idle")

func play_motion(motion_name: String) -> bool:
    if player == null or (defeated and motion_name != "hit"):
        return false
    var animation_name := "titan/" + motion_name
    if not player.has_animation(animation_name):
        return false
    if player.is_playing() and player.current_animation == animation_name:
        return true
    return bool(player.call("play_motion", motion_name))

func _on_animation_finished(animation_name: StringName) -> void:
    if defeated:
        return
    if animation_name in [&"titan/attack", &"titan/cast", &"titan/hit"]:
        var hero := get_parent()
        var team := hero.get_parent() if hero != null else null
        play_motion("run" if team != null and bool(team.get("is_walking")) else "idle")

func mark_defeated() -> void:
    if defeated:
        return
    defeated = true
    play_motion("hit")

func restore() -> void:
    defeated = false
    if player != null:
        player.stop()
    if skeleton != null:
        skeleton.reset_bone_poses()
    play_motion("idle")
