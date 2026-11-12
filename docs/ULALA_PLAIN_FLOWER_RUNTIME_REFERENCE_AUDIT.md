# Ulala Plain: flower-group runtime activation reference audit

Purpose: isolate whether other serialized objects point to the ten inactive
`hua_001_group`/`hua_002_group` parents. The known baseline is **496
flower children under 10 inactive parent GameObjects**. An active MeshRenderer
on an inactive hierarchy is not evidence of visible flowers.

## New reproducible probe

```sh
python -m pip install UnityPy
python tools/audit_plain_flower_activation_refs.py \
  --scene /local/private/plain.unity_ab \
  --output /local/private/plain_flower_activation_refs.json
python -m unittest tests.test_plain_flower_activation_refs
```

The tool checks actual, explicit PPtr references in readable `MonoBehaviour`
TypeTrees, and counts potential `AnimationClip` names as *unverified leads*.
It deliberately exports aggregate counts only, not original assets or path IDs.

**Do not interpret a direct reference as a verified activation call.**
A negative result also cannot rule out `GameObject.Find`, scene-manager
references from different bundles, external Mono assemblies, Animator bindings,
prefab-instantiation, dynamically loaded scenes, or native runtime code.

## Status

- Previous source research: ten parent GameObjects inactive and directly
  attached components consist only of Transform.
- This new audit script is checked in, but **its original-scene scan has not
  been executed or verified here** because the proprietary source bundle is
  not checked into GitHub.
- Follow-up after obtaining its aggregate JSON: check cross-bundle references,
  named animation bindings and managed activation callsites before claiming
  actual runtime visibility.

## Scan completeness / interpretation

The current probe also counts all GameObjects encountered and reports how many
TypeTrees could not be read. Its candidate classes include MonoBehaviour,
AnimationClip, Animator, AnimatorController and PlayableDirector, with candidate
direct references aggregated by component class.

- `partial_scan_unreadable_objects`: results are incomplete; a zero cannot
  establish absence of references.
- `direct_reference_candidates_found`: serialized references exist, but
  actual activation remains unproven.
- `no_direct_references_in_scanned_classes`: only a negative for the enumerated
  objects, PPtr format and classes in the supplied scene, not for external code.

The workflow's Python tests use synthetic pointer records only. They do not
decode the original `BuildPlayer-Plain` scene nor validate runtime visibility.
