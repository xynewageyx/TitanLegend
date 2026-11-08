#!/usr/bin/env python3
"""Advisory Android scene-complexity estimates from measured Godot imports.

Not a device FPS benchmark. Does not fail builds for arbitrary polygon limits.
"""
import argparse
import csv
from pathlib import Path

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--comparison", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    with args.comparison.open(newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    if len(rows) != 9:
        raise SystemExit(f"Expected 9 forest models, found {len(rows)}")
    enemies = {r["enemy"]: r for r in rows}
    regular = sorted(k for k in enemies if k.startswith("forest_0"))
    if len(regular) != 6:
        raise SystemExit(f"Expected 6 regular forest mobs, found {regular}")
    boss = "forest_boss_01_wurzelkoenig"
    if boss not in enemies:
        raise SystemExit("Forest boss missing")
    def count(key, field):
        return int(enemies[key][field])
    # Stress scenario: 7 regular mobs in one wave. Model reuse means
    # the GPU may still process geometry per visible instance.
    heaviest = max(regular, key=lambda k: count(k, "godot_triangles"))
    scenarios = [
        ("7x heaviest regular enemy", 7, heaviest),
        ("1x forest boss", 1, boss),
    ]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=[
            "scenario", "enemy_id", "instances", "enemy_triangles_each",
            "estimated_enemy_triangles", "estimated_enemy_surfaces",
            "scope", "warning"])
        writer.writeheader()
        for label, n, key in scenarios:
            triangles = count(key, "godot_triangles")
            surfaces = count(key, "godot_surfaces")
            writer.writerow(dict(
                scenario=label, enemy_id=key, instances=n,
                enemy_triangles_each=triangles,
                estimated_enemy_triangles=triangles * n,
                estimated_enemy_surfaces=surfaces * n,
                scope="enemies only; excludes 4 heroes, pets, FX, UI, terrain",
                warning="Not FPS or actual draw-call count; profile on Android hardware"))
    print(f"FOREST ANDROID COMPLEXITY ESTIMATE PASSED: {len(scenarios)} scenarios")

if __name__ == "__main__":
    main()
