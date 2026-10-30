import hashlib
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).parent / 'generated' / 'asset_inventory.json'
EXTENSIONS = {'.glb','.gltf','.png','.jpg','.jpeg','.webp','.ogg','.wav'}

def main():
    assets = []
    for base in (ROOT / 'assets',):
        if base.exists():
            for path in sorted(base.rglob('*')):
                if path.is_file() and path.suffix.lower() in EXTENSIONS:
                    assets.append({'path': path.relative_to(ROOT).as_posix(), 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()})
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({'assets': assets}, indent=2) + '\n', encoding='utf-8')
    print(f'Indexed {len(assets)} assets')

if __name__ == '__main__': main()
