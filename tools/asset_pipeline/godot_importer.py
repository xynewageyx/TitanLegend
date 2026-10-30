import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
BASE = Path(__file__).parent / 'generated'

def main():
    inventory = BASE / 'asset_inventory.json'
    if not inventory.exists():
        raise SystemExit('Run asset_manager.py first')
    assets = json.loads(inventory.read_text(encoding='utf-8'))['assets']
    entries = []
    for asset in assets:
        path = (ROOT / asset['path']).resolve()
        if not path.is_relative_to(ROOT.resolve()) or not path.is_file():
            raise SystemExit('Unsafe or missing asset: ' + asset['path'])
        entries.append({'source': asset['path'], 'godot_resource': 'res://' + asset['path']})
    output = BASE / 'godot_import_manifest.json'
    output.write_text(json.dumps({'resources': entries}, indent=2) + '\n', encoding='utf-8')
    print(f'Validated {len(entries)} Godot resource paths')

if __name__ == '__main__': main()
