extends SceneTree

const STORE = preload("res://scripts/save_file_store.gd")
const TEST_PATH: String = "user://ci_save_integrity_test.json"

func _initialize() -> void:
    call_deferred("_run_tests")

func _run_tests() -> void:
    for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
        var path: String = TEST_PATH + str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

    if not STORE.load_latest(TEST_PATH).is_empty():
        _fail("Missing game save must return an empty dictionary")
        return

    var original := {"version": 1, "stage": 250, "wave": 4, "gold": 1250, "character_level": 30}
    if STORE.save_atomic(TEST_PATH, original) != OK:
        _fail("Could not save initial legacy-format progress")
        return
    if STORE.load_latest(TEST_PATH) != original:
        _fail("Initial save did not roundtrip")
        return

    var new_data := {"version": 1, "stage": 251, "wave": 2, "gold": 2500, "character_level": 31}
    if STORE.save_atomic(TEST_PATH, new_data) != OK:
        _fail("Could not update progress")
        return
    if STORE.load_latest(TEST_PATH) != new_data:
        _fail("Most recent save should be primary")
        return
    if STORE.load_latest(TEST_PATH + ".bak") != original:
        _fail("Backup should contain previous valid save")
        return

    var bad_progress := {"version": 1, "stage": -2, "wave": 9, "gold": -100}
    if STORE.save_atomic(TEST_PATH, bad_progress) == OK:
        _fail("Negative progress should be rejected")
        return
    if STORE.load_latest(TEST_PATH) != new_data:
        _fail("Invalid save attempt overwrote valid progress")
        return

    var corrupted := FileAccess.open(TEST_PATH, FileAccess.WRITE)
    if corrupted == null:
        _fail("Could not simulate interrupted save")
        return
    corrupted.store_string("{bad json")
    corrupted.close()
    if STORE.load_latest(TEST_PATH) != original:
        _fail("A corrupted primary did not restore the last good backup")
        return

    var recovered := {"version": 1, "stage": 252, "wave": 1, "gold": 3000}
    if STORE.save_atomic(TEST_PATH, recovered) != OK:
        _fail("Could not save resumed game after backup recovery")
        return
    if STORE.load_latest(TEST_PATH) != recovered:
        _fail("Resumed game was not saved")
        return
    if STORE.load_latest(TEST_PATH + ".bak") != original:
        _fail("Recovery overwrote the valid backup with corrupt data")
        return

    var no_gold := {"stage": 7, "wave": 1}
    if STORE.save_atomic(TEST_PATH, no_gold) == OK:
        _fail("Missing required save fields accepted")
        return

    for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
        var path: String = TEST_PATH + str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    print("Titan Legends automatic save integrity tests passed.")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
