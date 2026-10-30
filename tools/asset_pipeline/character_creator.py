"""Generate canonical hero design specifications; no meshes are produced here."""
import json
from pathlib import Path

# Must match scripts/team_formation.gd CLASS_NAMES order and indices.
CLASSES = [
    ("Krieger", "Warrior", "front", "broad armored silhouette", "sword and shield"),
    ("Paladin", "Paladin", "front", "radiant plated silhouette", "hammer and shield"),
    ("Druide", "Druid", "back", "leaf mantle and antler silhouette", "nature staff"),
    ("Schamane", "Shaman", "back", "totem and feather silhouette", "spirit totem"),
    ("Jaeger", "Hunter", "back", "hood and quiver silhouette", "bow"),
    ("Schurke", "Rogue", "front", "agile scarf silhouette", "twin daggers"),
    ("Magier", "Mage", "back", "pointed mantle silhouette", "arcane staff"),
    ("Hexer", "Warlock", "back", "dark runic silhouette", "ritual focus"),
    ("Beschwoerer", "Summoner", "back", "floating sigil silhouette", "summoning tome"),
    ("Priester", "Priest", "back", "bright ceremonial silhouette", "healing staff"),
    ("Raufbold", "Brawler", "front", "oversized gauntlet silhouette", "gauntlets"),
]
OUT = Path(__file__).parent / "generated" / "heroes.json"


def build_heroes():
    return [
        {
            "id": name.lower(),
            "class_id": index,
            "game_name": name,
            "class": english,
            "formation_hint": formation,
            "silhouette": silhouette,
            "signature_equipment": equipment,
            "style": "original colorful stylized 3D chibi fantasy",
            "proportions": {"head_to_body_ratio": 0.34, "body_height_units": 3.0},
            "reference_views": ["front", "side", "back"],
            "expressions": ["neutral", "happy", "angry", "hurt", "determined"],
            "rig": "humanoid",
            "animations": ["idle", "walk", "attack", "cast", "hit", "dodge"],
            "skill_slots": 4,
            "asset_status": "design_spec_only",
        }
        for index, (name, english, formation, silhouette, equipment) in enumerate(CLASSES)
    ]


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    heroes = build_heroes()
    assert len(heroes) == 11 and len({h["class_id"] for h in heroes}) == 11
    OUT.write_text(json.dumps({"heroes": heroes}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUT} ({len(heroes)} hero design specifications; no 3D models)")


if __name__ == "__main__":
    main()
