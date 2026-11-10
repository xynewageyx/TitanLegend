# Ulala reference — verified skinning, bindposes and dly/ndly discrepancy audit

Date: 2026-11-10. Technical reference analysis only. Do not import proprietary Ulala meshes, rigs, textures, animations or bindpose matrices into Titan Legends.

## Scope and measured results

The nine-part Google Drive reference archive was accessed in a previous local analysis. The recorded results are:
- 88 of 88 separate AnimationClip bundles parsed, yielding 19,794 generic binding entries and 702 distinct binding-path hashes.
- 698 distinct hashes have unique CRC32 transform-path candidates in the scanned prefab hierarchies; 650 also coincide with referenced SkinnedMeshRenderer.m_Bones; 48 have transform-only evidence; three hashes remain unmatched; hash 0x00000000 represents the empty/root binding path and is not a bone.
- The 650 referenced hashes are not evidence that 650 bindposes have been independently validated or that Godot retargeting works.
- For five selected Unity Shared bundles, 57 Mesh/SkinnedMeshRenderer associations were linked, with 457 local renderer-bone references and corresponding bindpose matrices.
- Comparing bindposes to inverse(BoneWorldRest) * RendererWorldRest using the tested matrix layout: 402/457 within a maximum element discrepancy of 0.001; 439/457 within 0.01; 18 values remain above 0.01 in four meshes.
- The 18 outliers represent eight finger bones and one weapon-hand bone in each of the dly/ndly variants.

## Independent variant crosscheck

Compared the 16 Float32 matrix elements directly from original Unity Mesh.m_BindPose values, with renderer bone identification by local Transform path IDs.

- Eight corresponding finger-bone bindposes in dly vs. ndly: maximum absolute matrix-element difference: 1.043081284e-07 (near-identical, not bit-exact).
- Weapon hand: maximum absolute element difference 0.078783542.
- The relative weapon-hand transform between dly and ndly bindposes is approximately 0.080009 Unity units translation, approximately 0 degrees rotation and unit-like scale.
- A **different** comparison of each bindpose with its computed Prefab-rest transform previously found 0.73–1.70 degree finger rotations and approximately 87.22 degree weapon-hand rotation. These two comparisons must **not** be conflated.

## Interpretation and limitations

The dly/ndly weapon-hand translation could be intentional equipment authoring offset or another difference in source transforms. Do not automatically alter original rest poses, weapon grips or animation tracks.

The comparison is wholly within the reference Unity model data. No complete Godot 4.7.2 Skeleton3D rest-inventory for all twelve Titan Legends classes (Death Knight included) was validated by this investigation, and playable animation transfer is unverified.

## Required follow-up

1. Decode Avatar.m_AvatarSkeletonPose and skeleton hierarchy, verify per-index correspondence rather than trusting names.
2. Cross-validate bindpose matrix orientation and transform composition with a second independent decoder.
3. Run `tools/export_skeleton3d_inventory.gd` on all actual Godot class GLBs; verify missing classes and imported skeletons.
4. Compare only abstract hierarchy/topology/pose properties and author original Titan Legends rigs and animations.
5. Validate resulting independently authored combat animations on Android, across quality tiers.

Source tools already in repository: `tools/decode_unity_animation_clip_values.py`, `tools/audit_unity_rig_hash_coverage.py`, `tools/verify_bone_hierarchy_hashes.py`, `tools/export_skeleton3d_inventory.gd`.

No third-party proprietary asset data is included in this report.
