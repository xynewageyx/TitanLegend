extends Node
## Local audio lifecycle bridge. The authoritative network session must call
## apply_authoritative_team_snapshot after validating the server's team payload.
## Never derive ownership from class, formation position, or client input.

signal audio_ownership_changed(ready: bool)

func apply_authoritative_team_snapshot(owner_peer_ids: Array[int], class_ids: Array[int], local_peer_id: int) -> bool:
 var bound: bool = AudioManager.bind_local_hero_with_classes(owner_peer_ids, class_ids, local_peer_id)
 audio_ownership_changed.emit(bound)
 return bound

func on_team_changed(owner_peer_ids: Array[int], class_ids: Array[int], local_peer_id: int) -> bool:
 return apply_authoritative_team_snapshot(owner_peer_ids, class_ids, local_peer_id)

func on_character_changed(owner_peer_ids: Array[int], class_ids: Array[int], local_peer_id: int) -> bool:
 return apply_authoritative_team_snapshot(owner_peer_ids, class_ids, local_peer_id)

func on_session_disconnected() -> void:
 AudioManager.clear_local_hero()
 audio_ownership_changed.emit(false)
