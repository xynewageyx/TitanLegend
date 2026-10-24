extends RefCounted
## Atomisches, abwaertskompatibles Dateispeichern mit einer gesunden Sicherung.
## Nur Dateien im lokalen Godot-user://-Ordner; kein Cloud-Sync.
const MAX_SAVE_BYTES: int = 2097152

static func _read_valid(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var stream := FileAccess.open(path, FileAccess.READ)
    if stream == null:
        return {}
    if stream.get_length() <= 0 or stream.get_length() > MAX_SAVE_BYTES:
        stream.close()
        return {}
    var parsed: Variant = JSON.parse_string(stream.get_as_text())
    stream.close()
    if not parsed is Dictionary:
        return {}
    var data: Dictionary = parsed
    # Legacy-Spielstaende von SaveManager v1 enthalten diese Pflichtfelder.
    if not data.has("stage") or not data.has("wave") or not data.has("gold"):
        return {}
    if not (data["stage"] is int or data["stage"] is float):
        return {}
    if not (data["wave"] is int or data["wave"] is float):
        return {}
    if not (data["gold"] is int or data["gold"] is float):
        return {}
    if int(data["stage"]) < 1 or int(data["wave"]) < 1 or int(data["wave"]) > 10:
        return {}
    if int(data["gold"]) < 0:
        return {}
    return data

static func load_latest(path: String) -> Dictionary:
    var current := _read_valid(path)
    if not current.is_empty():
        return current
    var backup := _read_valid(path + ".bak")
    if not backup.is_empty():
        push_warning("Spielstand aus lokaler Sicherung wiederhergestellt; Hauptdatei war nicht lesbar.")
    elif FileAccess.file_exists(path):
        push_warning("Hauptspielstand konnte nicht gelesen werden; keine gueltige Sicherung vorhanden.")
    return backup

static func save_atomic(path: String, data: Dictionary) -> Error:
    if not path.begins_with("user://") or _readable_data_invalid(data):
        return ERR_INVALID_PARAMETER
    var serialized := JSON.stringify(data)
    if serialized.to_utf8_buffer().size() > MAX_SAVE_BYTES:
        return ERR_OUT_OF_MEMORY
    var temporary := path + ".tmp"
    var stream := FileAccess.open(temporary, FileAccess.WRITE)
    if stream == null:
        return FileAccess.get_open_error()
    stream.store_string(serialized)
    stream.flush()
    stream.close()
    # Nur ein vollstaendiger, validierter neuer Spielstand darf die Hauptdatei ersetzen.
    if _read_valid(temporary).is_empty():
        DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary))
        return ERR_FILE_CORRUPT
    # Eine vorherige gueltige Hauptdatei wird zur Rettungskopie rotiert.
    # Ein beschaedigter Hauptspielstand darf die letzte gute .bak NICHT ersetzen.
    if not _read_valid(path).is_empty():
        var backup_temp := path + ".bak.tmp"
        var copy_result := DirAccess.copy_absolute(
            ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(backup_temp)
        )
        if copy_result != OK:
            return copy_result
        if _read_valid(backup_temp).is_empty():
            DirAccess.remove_absolute(ProjectSettings.globalize_path(backup_temp))
            return ERR_FILE_CORRUPT
        var rotate_result := DirAccess.rename_absolute(
            ProjectSettings.globalize_path(backup_temp),
            ProjectSettings.globalize_path(path + ".bak")
        )
        if rotate_result != OK:
            return rotate_result
    return DirAccess.rename_absolute(
        ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(path)
    )

static func _readable_data_invalid(data: Dictionary) -> bool:
    if not data.has("stage") or not data.has("wave") or not data.has("gold"):
        return true
    if not (data["stage"] is int or data["stage"] is float):
        return true
    if not (data["wave"] is int or data["wave"] is float):
        return true
    if not (data["gold"] is int or data["gold"] is float):
        return true
    return int(data["stage"]) < 1 or int(data["wave"]) < 1 or int(data["wave"]) > 10 or int(data["gold"]) < 0
