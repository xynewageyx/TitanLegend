extends RefCounted
class_name TitanTalentSystem

# Klassenindex entspricht TeamFormation.CLASS_NAMES.
# Jede Klasse besitzt drei eigene Spezialisierungen.
const MAX_RANK: int = 500
const TREE_NAMES := [
 ["Waffenmeister", "Bollwerk", "Kampfgeist"],
 ["Vergeltung", "Heiliger Schild", "Segen"],
 ["Wildheit", "Baumrinde", "Lebenskreis"],
 ["Sturmrufer", "Erdenwaechter", "Ahnenheilung"],
 ["Praezision", "Ausweichen", "Feldkunde"],
 ["Hinterhalt", "Schattenmantel", "Giftkunde"],
 ["Arkanmacht", "Magiebarriere", "Manastrom"],
 ["Fluchmagie", "Seelenpanzer", "Lebensentzug"],
 ["Beschwoerungsmacht", "Runenschutz", "Seelenbund"],
 ["Lichtstrahl", "Glaubensschild", "Heilkunst"],
 ["Fauststurm", "Eisenhaut", "Kampftrance"]
]
# Klasse und Baum beeinflussen Angriff, Schadensminderung und Heilung unterschiedlich.
# Zahlen sind Boni PRO RANG; Endboni werden gedeckelt.
const OFFENSE := [0.006, 0.005, 0.004, 0.005, 0.007, 0.008, 0.008, 0.007, 0.006, 0.003, 0.007]
const DEFENSE := [0.006, 0.007, 0.007, 0.006, 0.004, 0.004, 0.004, 0.005, 0.005, 0.006, 0.006]
const SUPPORT := [0.003, 0.006, 0.008, 0.007, 0.003, 0.002, 0.004, 0.004, 0.005, 0.009, 0.003]

# Meilensteine: je Talentbaum bei Rang 10, 25, 50 und 100.
# Der Bonus wird zusaetzlich zum normalen passiven Talentwert berechnet.
const MILESTONE_RANKS := [10, 25, 50, 100]
const MILESTONE_NAMES := ["I: Erwachen", "II: Meisterschaft", "III: Durchbruch", "IV: Legende"]

static func milestone_count(rank: int) -> int:
 var count: int = 0
 for required in MILESTONE_RANKS:
  if rank >= required:
   count += 1
 return count

static func next_milestone(rank: int) -> String:
 for index in range(MILESTONE_RANKS.size()):
  if rank < int(MILESTONE_RANKS[index]):
   return str(MILESTONE_NAMES[index]) + " bei Rang " + str(MILESTONE_RANKS[index])
 return "Alle Meilensteine freigeschaltet"

static func milestone_description(class_id: int, tree: int, rank: int) -> String:
 var name: String = str(TREE_NAMES[clampi(class_id, 0, 10)][clampi(tree, 0, 2)])
 var count: int = milestone_count(rank)
 return name + ": " + str(count) + "/4 | " + next_milestone(rank)

static func points_available(character_level: int) -> int:
 return maxi(0, (maxi(1, character_level) - 1) * 3)

static func tree_title(class_label: String, tree: int) -> String:
 var class_id: int = _class_index(class_label)
 return str(TREE_NAMES[class_id][clampi(tree, 0, 2)])

static func _class_index(class_label: String) -> int:
 const NAMES := ["Krieger", "Paladin", "Druide", "Schamane", "Jaeger", "Schurke", "Magier", "Hexer", "Beschwoerer", "Priester", "Raufbold"]
 var index: int = NAMES.find(class_label)
 return maxi(0, index)

static func description_for_class(class_id: int, tree: int, rank: int) -> String:
 var bonus: float = 0.0
 var label: String = ""
 match tree:
  0:
   bonus = minf(0.75, rank * float(OFFENSE[class_id]) * 0.25 + 0.015 * milestone_count(rank))
   label = "Angriff"
  1:
   bonus = minf(0.35, rank * float(DEFENSE[class_id]) * 0.20 + 0.01 * milestone_count(rank))
   label = "Schadensschutz"
  _:
   bonus = minf(0.75, rank * float(SUPPORT[class_id]) * 0.20 + 0.015 * milestone_count(rank))
   label = "Heilkraft"
 return "+" + str(int(round(bonus * 100.0))) + "% " + label if tree != 1 else str(int(round(bonus * 100.0))) + "% " + label

# Pro Talentbaum zwei Spezialisierungswege ab Rang 25.
# Weg A verstaerkt den primaeren Effekt; Weg B gewaehrt einen hybriden Bonus.
const BRANCH_NAMES := ["Meisterpfad", "Hybridpfad"]
const BRANCH_UNLOCK_RANK: int = 25

static func branch_description(tree: int, branch: int) -> String:
 if branch == 0:
  return ["+10 % Baum-Angriff", "+10 % Baum-Schutz", "+10 % Baum-Heilung"][clampi(tree, 0, 2)]
 return ["+3 % Teamschutz", "+3 % Teamschaden", "+3 % Teamheilung"][clampi(tree, 0, 2)]

static func team_bonuses(class_ids: Array, talent_ranks: Array, branches: Array = []) -> Dictionary:
 var attack: float = 0.0
 var defense: float = 0.0
 var healing: float = 0.0
 for slot in range(mini(class_ids.size(), talent_ranks.size())):
  var class_id: int = clampi(int(class_ids[slot]), 0, 10)
  var ranks: Array = talent_ranks[slot]
  if ranks.size() < 3:
   continue
  attack += minf(0.75, maxi(0, int(ranks[0])) * float(OFFENSE[class_id])) + 0.025 * milestone_count(int(ranks[0]))
  defense += minf(0.50, maxi(0, int(ranks[1])) * float(DEFENSE[class_id])) + 0.015 * milestone_count(int(ranks[1]))
  healing += minf(0.75, maxi(0, int(ranks[2])) * float(SUPPORT[class_id])) + 0.025 * milestone_count(int(ranks[2]))
  if slot < branches.size() and branches[slot] is Array:
   var picks: Array = branches[slot]
   for tree in range(mini(3, picks.size())):
    if int(ranks[tree]) < BRANCH_UNLOCK_RANK:
     continue
    var choice: int = int(picks[tree])
    if choice == 0:
     match tree:
      0: attack += minf(0.75, float(ranks[tree]) * float(OFFENSE[class_id])) * 0.10
      1: defense += minf(0.50, float(ranks[tree]) * float(DEFENSE[class_id])) * 0.10
      2: healing += minf(0.75, float(ranks[tree]) * float(SUPPORT[class_id])) * 0.10
    elif choice == 1:
     match tree:
      0: defense += 0.03
      1: attack += 0.03
      2: healing += 0.03
 return {"attack": minf(1.5, attack), "defense": minf(0.70, defense), "healing": minf(1.5, healing)}
