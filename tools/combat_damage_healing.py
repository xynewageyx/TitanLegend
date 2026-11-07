"""Deterministic damage/healing formula probes based on battle_manager.gd.

Explicit inputs model progression, crit and healing. Does not execute Godot,
randomness, skill damage, mitigation or full PvP combat.
"""
from pathlib import Path
import re

SOURCE = (Path(__file__).resolve().parents[1] / "scripts/battle_manager.gd").read_text(encoding="utf-8")


def source_method(name):
    match = re.search(r"(?m)^func " + re.escape(name) + r"\(", SOURCE)
    if not match:
        raise ValueError("Missing method: " + name)
    next_method = re.search(r"(?m)^func ", SOURCE[match.end():])
    return SOURCE[match.start():match.end() + next_method.start()] if next_method else SOURCE[match.start():]


def godot_round(value):
    """Godot roundi() ties away from zero for nonnegative combat inputs."""
    return int(value + 0.5)


def normal_hit(level, role_multiplier, progression_attack=1.0,
               critical=False, crit_damage_bonus=0.0):
    if level < 1 or role_multiplier < 0 or progression_attack < 0 or crit_damage_bonus < 0:
        raise ValueError("Invalid combat inputs")
    base = 35 + level * 6
    crit_factor = 1.6 + crit_damage_bonus if critical else 1.0
    return max(1, godot_round(base * role_multiplier * progression_attack * crit_factor))


def critical_chance(pet_crit):
    return min(0.30, 0.10 + pet_crit)


def heal_party(hp, maximum, amount, group=False):
    if len(hp) != 4 or len(maximum) != 4 or amount < 0:
        raise ValueError("Invalid party or healing")
    if any(max_hp <= 0 or health < 0 or health > max_hp for health, max_hp in zip(hp, maximum)):
        raise ValueError("Invalid health values")
    result = list(hp)
    if amount == 0:
        return result
    if group:
        increment = max(1, godot_round(amount / 4))
        for i in range(4):
            if result[i] > 0:
                result[i] = min(maximum[i], result[i] + increment)
    else:
        alive = [i for i in range(4) if result[i] > 0]
        if alive:
            target = min(alive, key=lambda i: result[i] / maximum[i])
            result[target] = min(maximum[target], result[target] + amount)
    return result


def boss_self_heal(current, maximum):
    if maximum <= 0 or not 0 <= current <= maximum:
        raise ValueError("Invalid boss health")
    return min(maximum, current + max(1, godot_round(maximum * 0.05)))
