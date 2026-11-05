# Titan Legends – Modular character rig v1

## Status
Implementation scaffold, not a finished rigged 3D character. Verified metadata from docs/ULALA_CHARACTER_HIERARCHIES.md is used only as a technical reference. No proprietary assets included.

## Scene contract
Attach scripts/character/modular_character.gd to a Node3D character root. Add a child Skeleton3D named Skeleton3D and a Node3D named Slots. Missing slot nodes are created at runtime. Equipped modules must be original PackedScenes rooted at Node3D.

Slots: hair, head, torso, gloves, legs, boots, main_hand, off_hand, back.

Slots are organizational nodes, not automatic bone attachments. Weapon anchors must use BoneAttachment3D bound to the original Titan rig. Skinned equipment requires matching rest poses, bone names, and explicit skeleton binding.

## Twelve classes
warrior, paladin, druid, shaman, hunter, rogue, mage, warlock, summoner, priest, brawler, death_knight.

Death knight shares the humanoid rig contract while using a distinct heavy dark-armored silhouette, rune accents and oversized weapons.

## Acceptance tests
1. Export original base character as glTF 2.0 (.glb) with consistent rest pose and bone names.
2. Verify head, hand and back anchor mappings in Godot.
3. Validate actual skin indices and weights rather than inferring them from Transform counts.
4. Play idle, run, attack, hit and death animations in Godot.
5. Profile four heroes plus companions and enemies on Android.
6. Run Godot headless parsing and scene smoke tests before merging.

## Evidence limits
Ulala metadata confirms Beryl/Brook prefab relationships, selected mesh/avatar pointers and Chushi hair Transforms, but not full bone counts, complete skin weights or cross-character rig compatibility. No original Ulala assets may be imported or redistributed.
