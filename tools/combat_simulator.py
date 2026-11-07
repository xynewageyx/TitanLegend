"""Deterministic combat timing harness grounded in current Godot constants.

Damage/HP are explicit scenario inputs, NOT measured Titan Legends balance values.
This is a regression harness, not a substitute for in-engine combat/PvP tests.
"""
from dataclasses import dataclass
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
BATTLE = (ROOT / "scripts/battle_manager.gd").read_text(encoding="utf-8")
TEAM = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")


def number(pattern: str, source: str) -> float:
    match = re.search(pattern, source)
    if not match:
        raise ValueError(f"Missing Godot constant: {pattern}")
    return float(match.group(1))


BOSS_LIMIT = number(r"const BOSS_TIME_LIMIT:\s*float\s*=\s*([\d.]+)", BATTLE)
interval_match = re.search(r"const ROLE_ATTACK_INTERVALS:.*?=\s*\[([^]]+)\]", BATTLE)
if not interval_match:
    raise ValueError("Missing ROLE_ATTACK_INTERVALS")
INTERVALS = tuple(float(v.strip()) for v in interval_match.group(1).split(","))
names_match = re.search(r"const CLASS_NAMES\s*:=\s*\[([^\n]+)\]", TEAM)
if not names_match:
    raise ValueError("Missing CLASS_NAMES")
CLASS_NAMES = tuple(re.findall(r'"([^"]+)"', names_match.group(1)))
roles_match = re.search(r"const ALLOWED_ROLES\s*:=\s*(\[[^\n]+\])", TEAM)
if not roles_match:
    raise ValueError("Missing ALLOWED_ROLES")
import ast
ALLOWED_ROLES = tuple(tuple(x) for x in ast.literal_eval(roles_match.group(1)))


@dataclass(frozen=True)
class Hero:
    class_id: int
    role: int
    damage_per_hit: float


def simulate_boss(heroes: tuple[Hero, ...], boss_hp: float, limit: float = BOSS_LIMIT):
    """Simulate only base attack cadence; no skills, healing, CC or mitigation."""
    if len(heroes) != 4 or boss_hp <= 0 or limit <= 0:
        raise ValueError("Expected four heroes, positive boss HP and time limit")
    if sum(h.role == 0 for h in heroes) > 1:
        raise ValueError("Only one active tank allowed")
    for h in heroes:
        if not (0 <= h.class_id < len(CLASS_NAMES)):
            raise ValueError("Invalid class ID")
        if h.role not in ALLOWED_ROLES[h.class_id] or h.damage_per_hit < 0:
            raise ValueError("Invalid class role or damage")
    events = sorted(
        (round(INTERVALS[h.role] * tick, 9), slot, h.damage_per_hit)
        for slot, h in enumerate(heroes)
        for tick in range(1, int(limit / INTERVALS[h.role]) + 1)
        if INTERVALS[h.role] * tick <= limit + 1e-8
    )
    remaining = boss_hp
    for at, slot, damage in events:
        remaining -= damage
        if remaining <= 0:
            return {"won": True, "time": at, "remaining_hp": 0.0, "last_attacker": slot}
    return {"won": False, "time": limit, "remaining_hp": max(0.0, remaining), "last_attacker": None}


def standard_team(damage_per_hit: float = 10.0):
    """Example only: Warrior tank, Mage DD, Hunter DD, Priest healer."""
    return (Hero(0, 0, damage_per_hit), Hero(6, 1, damage_per_hit),
            Hero(4, 1, damage_per_hit), Hero(9, 2, damage_per_hit))


if __name__ == "__main__":
    print("Classes:", len(CLASS_NAMES), "Boss limit:", BOSS_LIMIT, "Role intervals:", INTERVALS)
    for hp in (100, 1000, 5000):
        print("Synthetic boss HP", hp, simulate_boss(standard_team(), hp))
