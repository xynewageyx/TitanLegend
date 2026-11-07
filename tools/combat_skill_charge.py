"""Skill-charge timing harness using Godot's _skill_hit_cost table.

This checks normal-hit charging and four-slot order only. It does not
pretend to simulate skill damage, healing, PvP or live Godot execution.
"""
from pathlib import Path
import re

SOURCE = (Path(__file__).resolve().parents[1] / "scripts" / "battle_manager.gd").read_text(encoding="utf-8")


def method(name):
    m = re.search(r"(?m)^func " + re.escape(name) + r"\(", SOURCE)
    if not m:
        raise ValueError(f"Missing Godot method {name}")
    end = re.search(r"(?m)^func ", SOURCE[m.end():])
    return SOURCE[m.start():m.end() + end.start()] if end else SOURCE[m.start():]


def skill_hit_cost(role, choice):
    if role not in (0, 1, 2) or not 0 <= choice <= 9:
        raise ValueError("Invalid role or skill")
    # The special-case costs and common match cases mirror the actual GDScript.
    # Guard them with source assertions in tests to prevent silent divergence.
    if role == 0 and choice == 8:
        return 3
    if role == 0 and choice == 9:
        return 5
    if role == 2 and choice == 8:
        return 4
    return {0: 2, 1: 3, 2: 4, 3: 2, 4: 4, 5: 5, 6: 3, 7: 4}.get(choice, 5)


def charge_sequence(role, loadout, normal_hits):
    """Return ordered (hit_number, slot_index, choice) casts for normal hits.

    Skill charge resets after each cast, as in _try_cast_charged_skill.
    A skill must be usable; this harness assumes all configured skills are usable.
    """
    if len(loadout) != 4 or normal_hits < 0:
        raise ValueError("Four skill slots and nonnegative hits required")
    if any(not 0 <= choice <= (9 if role == 0 else 8 if role == 2 else 7) for choice in loadout):
        raise ValueError("Invalid role loadout")
    charge, slot, casts = 0, 0, []
    for hit in range(1, normal_hits + 1):
        charge = min(5, charge + 1)
        if charge >= skill_hit_cost(role, loadout[slot]):
            casts.append((hit, slot, loadout[slot]))
            charge = 0
            slot = (slot + 1) % 4
    return casts
