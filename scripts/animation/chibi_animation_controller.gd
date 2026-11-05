extends Node
## Reusable animation-only adapter for imported Chibi GLB scenes.
## Gameplay/skill decisions remain with BattleManager; this node only plays clips.
class_name ChibiAnimationController

const ACTIONS := ["Idle", "Walk", "Attack", "Hit", "Dodge"]
var animation_player: AnimationPlayer
var action_clips: Dictionary = {}
var active_action := ""


func configure(character_root: Node) -> bool:
    animation_player = _find_player(character_root)
    action_clips.clear()
    active_action = ""
    if animation_player == null:
        push_warning("ChibiAnimationController: no AnimationPlayer found")
        return false
    for action in ACTIONS:
        var candidates: Array[StringName] = []
        for clip_name in animation_player.get_animation_list():
            var label := str(clip_name)
            if label == action or label.begins_with(action + "_"):
                candidates.append(clip_name)
        candidates.sort()
        action_clips[action] = candidates
    return true


func play_action(action: String, variant: int = 0) -> bool:
    if animation_player == null or not action_clips.has(action):
        return false
    var candidates: Array = action_clips[action]
    if candidates.is_empty():
        return false
    var index := posmod(variant, candidates.size())
    var clip_name: StringName = candidates[index]
    if active_action == action and animation_player.is_playing() and animation_player.current_animation == str(clip_name):
        return true
    animation_player.play(clip_name)
    active_action = action
    return true


func return_to_idle() -> bool:
    return play_action("Idle")


func available_actions() -> Dictionary:
    var counts := {}
    for action in ACTIONS:
        counts[action] = action_clips.get(action, []).size()
    return counts


func _find_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node as AnimationPlayer
    for child in node.get_children():
        var found := _find_player(child)
        if found != null:
            return found
    return null
