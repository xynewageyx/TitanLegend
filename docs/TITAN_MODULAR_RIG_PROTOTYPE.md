# Titan Legends – Original modular humanoid rig prototype

This is a deliberately **limited prototype**, ported and reviewed separately
from the conflicted character-development PR #10. It contains **no** Ulala
models, textures, animations, or copied game assets.

## Implemented in this branch

- `TitanHumanoidRigBuilder` creates an original 18-bone hierarchy with
  parent-relative rest transforms, and rejects overwriting existing skeletons.
- The builder creates 15 `BoneAttachment3D` sockets corresponding to the
  existing Titan Legends 13 armor slots plus both weapon sockets.
- `TitanModularCharacter` supports all 12 playable class names and boots
  the prototype skeleton at runtime in a standalone scene.
- The scene carries a socket equipment controller and an independent logical
  `Slots` collection for future skinned-asset integration.
- Equipped hair and armor can follow the head/chest bones through the existing
  equipment socket APIs.
- A focused Godot 4.7.2 CI validates the rig and hero scene. The shared
  Android build still verifies normal project exports.

## Not implemented / claims not made

- No final skinned hero mesh or skin weights are supplied.
- No full idle/attack/hit/death animation tracks or retargeting are supplied.
- The logical `equip_scene` API uses placeholder `Slots` nodes. These are
  **not** skeletal attachments. For cosmetic armor and hair use the
  `equip_socket_armor` / `equip_socket_hairstyle` APIs.
- Android FPS, draw calls, LOD, and live visual quality still need device tests.

This PR does not change the 4-player formation, skills, or gameplay rules.
