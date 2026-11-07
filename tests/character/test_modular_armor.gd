extends SceneTree
## Verify the original layered armor across 13 sockets and six rarity tiers.
const ARMOR_SCRIPT = preload("res://scripts/equipment/chibi_armor_piece.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)

func _run() -> void:
    var combinations := 0
    for slot_index in range(13):
        var counts: Array[int] = []
        for rarity in range(6):
            var armor := Node3D.new()
            armor.set_script(ARMOR_SCRIPT)
            armor.set("slot_index", slot_index)
            armor.set("rarity", rarity)
            armor.set("class_id", 11)
            root.add_child(armor)
            await process_frame
            var n := armor.get_child_count()
            if n < 2 or n > 12:
                _fail("Armor mesh count out of budget: slot %d tier %d count %d" % [slot_index, rarity, n])
                return
            for part in armor.get_children():
                if not part is MeshInstance3D or part.mesh == null:
                    _fail("Invalid mesh on slot %d tier %d" % [slot_index, rarity])
                    return
            counts.append(n)
            combinations += 1
            armor.queue_free()
            await process_frame
        if counts[5] <= counts[0]:
            _fail("Final rarity does not increase silhouette detail on slot %d" % slot_index)
            return
        if counts[4] > counts[5]:
            _fail("Final rarity lost geometry details on slot %d" % slot_index)
            return
    print("ARMOR SMOKE PASSED: %d armor combinations; 13 sockets, 6 rarities, death knight" % combinations)
    quit(0)
