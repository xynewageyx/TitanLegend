# Titan Legends — Original modular character rig contract (v1)

Status: implementation specification, **not** a completed rig or asset import.
Target: Godot 4.7.2, Android portrait, 11 original playable class models.

## Evidence boundary
The UnityFS reference research in `docs/ULALA_CHARACTER_HIERARCHIES.md` confirms prefab GameObject/Transform relationships and some Mesh/Avatar pointer destinations. It does **not** confirm skinning bone counts, rest poses, weight maps, or transferable animation rigs. No proprietary meshes, textures, or animations may be committed or reused.

## Original Godot/Blender hierarchy
```text
HeroRoot (Node3D)
  VisualRoot (Node3D)
    Skeleton3D / Armature
      Root
        Hips
          Spine
            Chest
              Neck
                Head
              Shoulder_L -> UpperArm_L -> Forearm_L -> Hand_L
              Shoulder_R -> UpperArm_R -> Forearm_R -> Hand_R
          UpperLeg_L -> LowerLeg_L -> Foot_L
          UpperLeg_R -> LowerLeg_R -> Foot_R
    BodyMesh (skinned)
    FaceMesh (skinned or head-bound)
    HairMesh (head-bound; optional additional secondary-motion bones)
    ClothesMesh (skinned)
    ArmorMeshes (modular; bound to compatible skeleton or bone attachments)
    WeaponMesh (Hand_R bone attachment)
  EquipmentController
  PassivePet (existing gameplay behavior unchanged)
```

This is a **proposed** target hierarchy. Existing eight-bone GLBs are a compatibility baseline; do not silently rename/remove their bones before updating the exporter, animation clips, Godot import adapters, and validation tests.

## Attachment contract
- Head: hair, helmet, facial accessories; preserve face/eyes visibility.
- Chest/spine: torso armor, cape/back items.
- Shoulders/arms/hands: armor parts follow the corresponding animated bones.
- Hips/legs/feet: belt, leg armor and boots follow their bones.
- Right hand: main weapon; left hand: optional offhand/shield.
- Cosmetic secondary bones may be omitted on low-end Android graphics profiles.
- Replacing a cosmetic mesh must not change role, skills, stats, team formation, or passive pet behavior.

## Implementation order
1. Capture current 11 GLB bone names and animation tracks as regression fixtures.
2. Extend Blender rig with chest/neck, forearms/hands and upper/lower legs; keep old bone names or provide an explicit mapping.
3. Rebind meshes and weapon sockets; inspect weights and clipping in Idle, Walk, Attack, Hit, Dodge.
4. Implement hair/helmet visibility and deterministic swap logic; avoid hair clipping through helmets.
5. Export original GLBs and validate animation tracks, skinning, material count, Android performance and import warnings.
6. Compare four-hero formation on an actual portrait Android screenshot.

## Acceptance criteria
- All 11 classes load without missing bones or materials in Godot 4.7.2.
- Every class retains working Idle, Walk, Attack, Hit and Dodge clips.
- Hair, chest armor and weapons can be swapped at runtime without recreating the hero.
- Weapon grip remains attached to the hand during attack and dodge.
- No copied third-party binary assets or animations enter the repository.
- A GitHub CI pass alone does not count as visual Android verification.
