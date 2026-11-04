#!/usr/bin/env python3
"""Validate local Unity AnimationClip probe results without reading copyrighted curves."""
import argparse
import collections
import json
import math
from pathlib import Path


def validate(probe):
    rows = probe['rows']
    errors = probe['errors']
    problems = []
    if probe['files'] != len(rows) + len(errors):
        problems.append('inconsistent total')
    seen = set()
    samples = collections.Counter()
    empty = []
    durations = []
    for row in rows:
        file = row['file']
        if file in seen:
            problems.append(f'duplicate file {file}')
        seen.add(file)
        if row['consumed'] != row['bytes']:
            problems.append(f'incomplete object {file}')
        values = row['values']
        starts = values.get('m_StartTime', [])
        stops = values.get('m_StopTime', [])
        rates = values.get('m_SampleRate', [])
        if len(starts) != 1 or len(stops) != 1 or len(rates) != 2:
            problems.append(f'unexpected numeric field cardinality {file}')
            continue
        if not all(math.isfinite(v) for v in starts + stops + rates):
            problems.append(f'nonfinite numeric value {file}')
            continue
        if stops[0] < starts[0]:
            problems.append(f'negative clip duration {file}')
        duration = stops[0] - starts[0]
        durations.append((duration, file))
        if duration == 0:
            empty.append(file)
        samples[str(rates)] += 1
    return {
        'files': probe['files'], 'fully_consumed': len(rows),
        'failed': len(errors), 'validation_problems': problems,
        'sample_rate_pairs': dict(sorted(samples.items())),
        'zero_duration_files': sorted(empty),
        'longest_duration_seconds': max((d for d, _ in durations), default=None),
        'longest_duration_files': sorted(f for d, f in durations if d == max((v for v, _ in durations), default=None)),
        'warning': 'Sample rates and duration are decoded values, not verified animation playback or rig compatibility.',
    }


def main():
    p = argparse.ArgumentParser()
    p.add_argument('probe', type=Path)
    p.add_argument('--output', type=Path)
    args = p.parse_args()
    result = validate(json.loads(args.probe.read_text(encoding='utf-8')))
    output = json.dumps(result, indent=2, ensure_ascii=False) + '\n'
    if args.output:
        args.output.write_text(output, encoding='utf-8')
    print(output)
    if result['validation_problems']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
