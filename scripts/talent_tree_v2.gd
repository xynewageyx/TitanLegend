extends RefCounted
## Data-driven per-hero talent allocation. Integration into battle/UI is separate.
const BALANCE = preload("res://scripts/progression_balance_v1.gd")
const TALENTS_PER_BRANCH: int = 15
const MAX_RANK: int = 5
const BRANCH_COUNT: int = 3
const HERO_COUNT: int = 4

static func empty_build() -> Array:
 var build: Array = []
 for branch in range(BRANCH_COUNT):
  var ranks: Array[int] = []
  ranks.resize(TALENTS_PER_BRANCH)
  ranks.fill(0)
  build.append(ranks)
 return build

static func spent_points(build: Array) -> int:
 var total: int = 0
 for branch in build:
  if not branch is Array:
   continue
  for rank in branch:
   total += clampi(int(rank), 0, MAX_RANK)
 return total

static func available_points(level: int, build: Array) -> int:
 # Unspent earned points remain visible even when all 225 talent ranks are filled.
 return maxi(0, BALANCE.talent_points_earned(level) - spent_points(build))

static func remaining_rank_capacity(build: Array) -> int:
 return maxi(0, BRANCH_COUNT * TALENTS_PER_BRANCH * MAX_RANK - spent_points(build))

static func can_upgrade(level: int, build: Array, branch: int, talent: int) -> bool:
 if branch < 0 or branch >= BRANCH_COUNT or talent < 0 or talent >= TALENTS_PER_BRANCH:
  return false
 if build.size() != BRANCH_COUNT:
  return false
 for branch_ranks in build:
  if not branch_ranks is Array or branch_ranks.size() != TALENTS_PER_BRANCH:
   return false
 var current_rank: int = int(build[branch][talent])
 if current_rank < 0 or current_rank >= MAX_RANK:
  return false
 if available_points(level, build) <= 0:
  return false
 if remaining_rank_capacity(build) <= 0:
  return false
 # Every row has three talents; unlock a new row after 5 ranks in earlier rows.
 var row: int = int(talent / 3)
 if row == 0:
  return true
 var earlier: int = 0
 for index in range(row * 3):
  earlier += clampi(int(build[branch][index]), 0, MAX_RANK)
 return earlier >= row * 5

static func upgrade(level: int, build: Array, branch: int, talent: int) -> bool:
 if not can_upgrade(level, build, branch, talent):
  return false
 build[branch][talent] = int(build[branch][talent]) + 1
 return true

static func validate_build(level: int, value: Variant) -> Array:
 var result: Array = empty_build()
 if not value is Array or value.size() != BRANCH_COUNT:
  return result
 # Reconstruct in row order, respecting prerequisites and earned points.
 for row in range(5):
  for branch in range(BRANCH_COUNT):
   if not value[branch] is Array or value[branch].size() != TALENTS_PER_BRANCH:
    continue
   for column in range(3):
    var index: int = row * 3 + column
    var desired: int = clampi(int(value[branch][index]), 0, MAX_RANK)
    for rank in range(desired):
     if not upgrade(level, result, branch, index):
      break
 return result

static func class_tree_names(class_id: String) -> Array:
 return BALANCE.CLASS_TREES.get(class_id, [])
