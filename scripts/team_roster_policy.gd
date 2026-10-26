extends RefCounted
class_name TitanTeamRosterPolicy

const TEAM_SIZE: int = 4
const BOT_POWER: float = 0.80
const HUMAN_POWER: float = 1.0
const REQUIRED_ROLES := [0, 1, 1, 2] # Tank, damage, damage, healer.

static func bot_multiplier(is_bot: bool) -> float:
	return BOT_POWER if is_bot else HUMAN_POWER

static func assign_roles(occupied: Array, preferred_roles: Array) -> Array[int]:
	# Human roles are reserved first; empty seats fill missing formation roles.
	var roles: Array[int] = [1, 1, 1, 1]
	var remaining: Array[int] = REQUIRED_ROLES.duplicate()
	for i in range(TEAM_SIZE):
		if i < occupied.size() and bool(occupied[i]):
			var role: int = clampi(int(preferred_roles[i]) if i < preferred_roles.size() else 1, 0, 2)
			roles[i] = role
			remaining.erase(role)
	for i in range(TEAM_SIZE):
		if i >= occupied.size() or not bool(occupied[i]):
			roles[i] = remaining.pop_front() if not remaining.is_empty() else 1
	return roles
