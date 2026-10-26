#!/usr/bin/env python3
"""Static regression guard for the ten-element landscape wiring.

Run with: python3 tests/test_biome_scene_wiring.py
This does not replace a Godot headless startup or Android export test.
"""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
scene = (ROOT / "scenes/main.tscn").read_text(encoding="utf-8")
biome = (ROOT / "scripts/biome_manager.gd").read_text(encoding="utf-8")
expected = ("FIRE", "WATER", "EARTH", "NATURE", "LIGHT",
            "SHADOW", "WIND", "ICE", "LIGHTNING", "CHAOS")

enum_match = re.search(r"enum\s+BiomeType\s*\{([^}]+)\}", biome)
assert enum_match, "BiomeType enumeration missing"
actual = tuple(part.strip() for part in enum_match.group(1).split(","))
assert actual == expected, f"Element order changed: {actual}"
assert "signal biome_changed" in biome
assert "biome_changed.emit(current_biome)" in biome
assert "func update_biome_from_stage(stage: int)" in biome
assert "func generate_terrain()" in biome
assert 'path="res://scripts/biome_manager.gd"' in scene
assert scene.count('[node name="BiomeManager"') == 1
assert '[node name="BattleLandscape"' not in scene, "Duplicate ground may overlap BiomeManager"
assert "procedural_battle_lane.gd" not in scene
print("PASS: ten elements, scene wiring, stage mapping and single terrain generator")
