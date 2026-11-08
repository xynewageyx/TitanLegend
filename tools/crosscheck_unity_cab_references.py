#!/usr/bin/env python3
"""Cross-check Unity external CAB references against local bundle byte strings.

Only aggregates and filenames are exported. A CAB byte-string occurrence is
NOT proof that the referenced object or CAB is resolvable.
"""
import argparse
from collections import defaultdict
import json
from pathlib import Path
import re

CAB = re.compile(rb'CAB-([0-9a-fA-F]{32})')


def crosscheck(references, paths):
    occurrences = defaultdict(set)
    for path in paths:
        for token in set(CAB.findall(path.read_bytes())):
            occurrences[token.decode('ascii').lower()].add(path.name)
    report = {}
    total = found = 0
    for owner, refs in sorted(references.items()):
        rows = []
        for ref in refs:
            match = CAB.search(ref.get('path', '').encode('utf-8'))
            token = match.group(1).decode('ascii').lower() if match else None
            names = sorted(occurrences.get(token, [])) if token else []
            total += 1
            found += bool(names)
            rows.append({'fileID': ref.get('fileID'), 'seen_in_files': names,
                         'seen_in_owner': owner in names,
                         'status': 'token_seen' if names else 'token_not_seen'})
        report[owner] = rows
    return {'scanned_files': len(paths), 'external_references': total,
            'references_with_token_seen': found,
            'references_without_token_seen': total - found,
            'per_owner': report,
            'caution': 'CAB token occurrences do not prove PPtr or asset resolution.'}


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--references', required=True, type=Path)
    p.add_argument('--bundles', nargs='+', required=True, type=Path)
    p.add_argument('--output', type=Path)
    a = p.parse_args()
    result = crosscheck(json.loads(a.references.read_text(encoding='utf-8')), a.bundles)
    content = json.dumps(result, ensure_ascii=False, indent=2) + '\n'
    if a.output:
        a.output.write_text(content, encoding='utf-8')
    print(content)


if __name__ == '__main__':
    main()
