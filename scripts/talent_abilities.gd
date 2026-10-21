extends RefCounted
class_name TitanTalentAbilities

# Aktive automatische Talente ab Rang 10, je Klasse und Baum.
# Ein Held kann alle drei Talente freischalten; die Effekte haben getrennte Cooldowns.
const UNLOCK_RANK: int = 10
const ABILITY_NAMES := [
 ["Wirbelhieb", "Stahlwall", "Kampfrausch"],
 ["Lichturteil", "Heilige Bastion", "Segenswelle"],
 ["Krallensturm", "Rindenpanzer", "Lebensbluete"],
 ["Blitzkette", "Erdschild", "Ahnenruf"],
 ["Praezisionsschuss", "Flinker Schritt", "Natursegen"],
 ["Schattenschnitt", "Nebelhuelle", "Giftregen"],
 ["Arkanexplosion", "Runenbarriere", "Manawelle"],
 ["Seelenbrand", "Dunkler Schutz", "Lebensraub"],
 ["Geistersturm", "Runenwall", "Seelenheil"],
 ["Lichtlanze", "Glaubenswall", "Grossheilung"],
 ["Fausthagel", "Eisenfaust", "Kampfmut"],
]

static func ability_name(class_id: int, tree: int) -> String:
 return str(ABILITY_NAMES[clampi(class_id, 0, 10)][clampi(tree, 0, 2)])

static func cooldown_ticks(tree: int, branch: int) -> int:
 # Meisterpfad: etwas haeufigere Aktivierung ab Rang 25.
 var base: int = [9, 12, 11][clampi(tree, 0, 2)]
 return base - (2 if branch == 0 else 0)

static func activate(class_id: int, tree: int, rank: int, branch: int, base_damage: int, max_hp: int) -> Dictionary:
 if rank < UNLOCK_RANK:
  return {"damage": 0, "heal": 0, "guard": 0.0, "name": ""}
 var scaling: float = 1.0 + minf(0.65, float(rank - UNLOCK_RANK) * 0.003)
 var branch_boost: float = 1.15 if branch == 0 else 1.0
 var damage: int = 0
 var heal: int = 0
 var guard: float = 0.0
 match tree:
  0:
   damage = int(round(float(base_damage) * 1.35 * scaling * branch_boost))
  1:
   guard = minf(0.42, 0.18 * scaling * branch_boost)
  2:
   heal = int(round(float(max_hp) * 0.085 * scaling * branch_boost))
 # Hybridpfad bietet eine zweite, schwache Wirkung.
 if branch == 1:
  match tree:
   0: guard = 0.06
   1: heal = int(round(float(max_hp) * 0.035))
   2: damage = int(round(float(base_damage) * 0.35))
 # Klassenidentitaet: zusaetzlicher Akzent auf der Hauptwirkung.
 if class_id in [4, 5, 6, 7, 10] and tree == 0:
  damage = int(round(float(damage) * 1.12))
 if class_id in [0, 1, 2] and tree == 1:
  guard = minf(0.48, guard + 0.04)
 if class_id in [1, 2, 3, 9] and tree == 2:
  heal = int(round(float(heal) * 1.12))
 return {"damage": damage, "heal": heal, "guard": guard, "name": ability_name(class_id, tree)}
