#!/usr/bin/env python3
"""Summarize Unity object classes from local metadata, without asset payloads."""
import argparse
import json
from collections import Counter
from pathlib import Path

CLASS_NAMES = {'1': 'GameObject', '4': 'Transform', '43': 'Mesh',
               '90': 'Avatar', '95': 'Animator', '137': 'SkinnedMeshRenderer',
               '142': 'AssetBundle', '221': 'AnimatorOverrideController'}


def summarize(entries):
    totals = Counter()
    items = []
    for entry in entries:
        counts = {str(k): int(v) for k, v in entry['classes'].items()}
        if sum(counts.values()) != entry['objects']:
            raise ValueError('Object count mismatch in ' + entry['file'])
        totals.update(counts)
        items.append({'file': entry['file'], 'objects': entry['objects'],
                      'transforms': counts.get('4', 0),
                      'meshes': counts.get('43', 0),
                      'skinned_renderers': counts.get('137', 0),
                      'avatars': counts.get('90', 0),
                      'animators': counts.get('95', 0),
                      'is_shared': entry['file'].endswith('_shared')})
    return {'bundles': len(items),
            'objects': sum(x['objects'] for x in items),
            'class_totals': {CLASS_NAMES.get(k, k): v for k, v in
                             sorted(totals.items(), key=lambda kv: int(kv[0]))},
            'bundles_detail': items}


def main():
    p = argparse.ArgumentParser()
    p.add_argument('object_counts', type=Path)
    p.add_argument('--output', type=Path)
    args = p.parse_args()
    result = summarize(json.loads(args.object_counts.read_text(encoding='utf-8')))
    rendered = json.dumps(result, ensure_ascii=False, indent=2) + '\n'
    if args.output:
        args.output.write_text(rendered, encoding='utf-8')
    print(rendered)


if __name__ == '__main__':
    main()
