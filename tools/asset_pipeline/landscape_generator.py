import json
from pathlib import Path
ELEMENTS = ['fire','water','earth','wind','ice','lightning','nature','light','dark','poison','metal','arcane']
OUT = Path(__file__).parent / 'generated' / 'biomes.json'

def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    biomes = [{'id': element, 'style': 'original colorful stylized low-poly fantasy', 'terrain_seed': 1000 + i, 'props': ['rocks','foliage','landmarks'], 'stages': 100} for i, element in enumerate(ELEMENTS)]
    OUT.write_text(json.dumps({'biomes': biomes}, indent=2) + '\n', encoding='utf-8')
    print(f'Wrote {OUT} ({len(biomes)} biome specifications)')

if __name__ == '__main__': main()
