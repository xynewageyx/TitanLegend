extends SceneTree

const RULES = preload("res://scripts/tank_interception_math.gd")

func _initialize() -> void:
 call_deferred("_run_cases")

func _run_cases() -> void:
 # HP, damage without shielding, damage with shielding, HP redirected.
 var cases: Array[Array] = [
  [100, 95, 65, 30],
  [1, 95, 65, 0],     # Ally dies regardless: no prevented HP to redirect.
  [80, 95, 65, 15],   # Overkill is not transferred to the tank.
  [70, 95, 65, 5],
  [500, 95, 65, 30],
  [100, 0, 0, 0],
  [0, 95, 65, 0],
  [50, 30, 40, 0],   # Shield must not create negative transferred damage.
  [-2, -4, -8, 0],
 ]
 for row in cases:
  var result: int = RULES.prevented_hp_loss(int(row[0]), int(row[1]), int(row[2]))
  if result != int(row[3]):
   push_error("Tank interception mismatch for %s: got %d" % [str(row), result])
   quit(1)
   return
 print("PASS: %d tank interception HP edge cases" % cases.size())
 quit(0)
