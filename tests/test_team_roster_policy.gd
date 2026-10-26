extends SceneTree
const POLICY = preload("res://scripts/team_roster_policy.gd")

func _initialize() -> void:
	assert(is_equal_approx(POLICY.bot_multiplier(true), 0.8))
	assert(is_equal_approx(POLICY.bot_multiplier(false), 1.0))
	var roles: Array[int] = POLICY.assign_roles([true, false, false, false], [0, 1, 1, 2])
	assert(roles.count(0) == 1, "Exactly one tank required")
	assert(roles.count(1) == 2, "Two damage roles required")
	assert(roles.count(2) == 1, "One healer required")
	var full_team: Array[int] = POLICY.assign_roles([true, true, true, true], [0, 1, 1, 2])
	assert(full_team == [0, 1, 1, 2])
	# A new player takes the vacant damage slot; the first tank keeps it.
	var joined: Array[int] = POLICY.assign_roles([true, true, false, false], [0, 1, 1, 2])
	assert(joined == [0, 1, 1, 2], "Joining must not displace the tank")
	var healer_joined: Array[int] = POLICY.assign_roles([true, false, false, true], [0, 1, 1, 2])
	assert(healer_joined == [0, 1, 1, 2], "Missing damage roles must be filled by bots")
	print("PASS: bot roster policy")
	quit()
