import json
from pathlib import Path
OUT = Path(__file__).parent / 'generated' / 'animations.json'
CLIPS = {'idle': True, 'walk': True, 'attack': False, 'cast': False, 'hit': False, 'dodge': False}

def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({'rig': 'humanoid', 'clips': [{'name': n, 'loop': loop} for n, loop in CLIPS.items()]}, indent=2) + '\n', encoding='utf-8')
    print(f'Wrote {OUT}')

if __name__ == '__main__': main()
