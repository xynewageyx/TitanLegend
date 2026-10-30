import json
from pathlib import Path

CLASSES = ['Warrior','Paladin','Berserker','Assassin','Hunter','Mage','Warlock','Druid','Priest','Shaman']
OUT = Path(__file__).parent / 'generated' / 'heroes.json'

def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    heroes = [{'id': name.lower(), 'class': name, 'style': 'original stylized 3D chibi fantasy', 'rig': 'humanoid', 'animations': ['idle','walk','attack','cast','hit','dodge'], 'skill_slots': 4} for name in CLASSES]
    OUT.write_text(json.dumps({'heroes': heroes}, indent=2) + '\n', encoding='utf-8')
    print(f'Wrote {OUT} ({len(heroes)} hero specifications)')

if __name__ == '__main__': main()
