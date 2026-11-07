"""Deterministic boss-cast interruption model based on battle_manager.gd.

Models CC requirement, window length and interrupt vulnerability only.
Not a complete Godot combat simulation or balance benchmark.
"""
from pathlib import Path
import re

SOURCE = (Path(__file__).resolve().parents[1] / "scripts/battle_manager.gd").read_text(encoding="utf-8")


def source_method(name):
    m = re.search(r"(?m)^func " + re.escape(name) + r"\(", SOURCE)
    if not m:
        raise ValueError(f"Missing Godot function: {name}")
    n = re.search(r"(?m)^func ", SOURCE[m.end():])
    return SOURCE[m.start():m.end() + n.start()] if n else SOURCE[m.start():]


def boss_cast(variant, cast_index, fusion=False):
    if variant not in range(4) or cast_index < 1:
        raise ValueError("Invalid boss variant or cast index")
    if variant == 0:
        kind, required = "single", (1 if cast_index % 3 == 0 else 0)
    elif variant == 1:
        kind, required = "aoe", (3 if fusion else 2)
    elif variant == 2:
        kind = "single" if cast_index % 2 == 0 else "self_heal"
        required = 0 if kind == "single" else 1
    else:
        kind = "aoe" if cast_index % 2 == 0 else "single"
        required = (2 if fusion else 1) if kind == "aoe" else 1
    return {"kind": kind, "required": required, "window_ticks": 3 + max(0, required - 1) * 2}


def interrupt_cast(cast, hits, skill_tick=0):
    """One CC hit per interrupt skill; non-interruptible casts cannot be stopped."""
    if hits < 0 or skill_tick < 0:
        raise ValueError("Invalid hit count or skill tick")
    required = cast["required"]
    interrupted = required > 0 and hits >= required
    return {
        "interrupted": interrupted,
        "progress": 0 if interrupted else min(hits, required),
        "vulnerable_until": skill_tick + 4 if interrupted else None,
    }
