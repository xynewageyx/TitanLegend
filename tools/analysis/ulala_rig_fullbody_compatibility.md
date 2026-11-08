# Titan Legends – read-only full-body / modular rig findings

This analysis uses locally decoded Unity 2019.4 character-bundle metadata **only as a technical reference**. It does not import, redistribute or reconstruct proprietary Ulala meshes, rigs, matrices, animation clips, textures, or materials.

## Original-data comparisons (8 bundles)

- 15 renderer-root groups have at least 20 distinct bone references.
- Ten large-group pairings have at least ten exactly matching bone names; five pairings span different bundles.
- `dly` vs. `ndly`: 65 vs. 66 referenced bones; **64 shared named bones** have identical parent names, local rest transforms and bindpose matrices (component-wise tolerance 1e-4). `dly` includes one neck bone absent from the matched `ndly` group, whereas `ndly` has two additional skirt bones. Therefore these are compatible **only across the shared 64-bone subset**, not as identical complete skeletons.
- `mdly` vs. `mjs`: two 34-bone hand/finger-rig comparisons match their entire named bone sets, parent names, rest transforms and bindpose matrices.
- `wdly` vs. `wjs`: two 34-bone hand/finger-rig comparisons likewise match.
- Identical hand/finger rigs are **not** equivalent to fully shared character rigs.

## Godot 4.7.2 smoke-test scope

`tests/test_modular_skeleton_pose_transfer.gd` builds **original synthetic** 65- and 66-bone `Skeleton3D` structures, with 64 shared bones and differing optional bones, and transfers five sampled poses via matching bone names. It exercises Godot's actual `Skeleton3D` runtime, but it does **not** test playback of original Ulala AnimationClips: those clips are not present in the eight analyzed character bundles.

**Do not mark imported animations or all twelve Titan Legends classes as validated** from this check alone. Separate tests with newly authored characters, skins, animations and Android GPU runtime are still required.
