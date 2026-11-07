# Ulala monster bundle: verified serialized-object findings (2026-11-06)

Source: user-provided nine-part Ulala backup, inspected locally. This document contains **metadata only**; do not copy proprietary geometry, textures, rigs, or clips into Titan Legends.

## Verified internal names
| Bundle | Unity class | Serialized object name |
|---|---|---|
| daduwa_yulin.prefab_ab_shared | Mesh | DaDuWa_huo |
| daduwa_yulin.prefab_ab_shared | Avatar | DaDuWa_YuLinAvatar |
| danxiaozhu_conglin.prefab_ab_shared | Mesh | DanXiaoZhu_CongLin |
| danxiaozhu_conglin.prefab_ab_shared | Avatar | DanXiaoZhu_CongLinAvatar |
| dujiaoxingboss.prefab_ab_shared | Mesh | DuJiaoXing |
| dujiaoxingboss.prefab_ab_shared | Mesh | ShiTou |
| dujiaoxingboss.prefab_ab_shared | Avatar | DuJiaoXingBossAvatar |
| guiboss.prefab_ab_shared | Mesh | wugui_boss |
| guiboss.prefab_ab_shared | Avatar | GuiBossAvatar |
| teshu_dujiaoxingboss.prefab_ab_shared | AnimationClip | fx_DuJiaoXingBoss_open |
| teshu_guiboss.prefab_ab_shared | Mesh | JuQianXie |
| teshu_guiboss.prefab_ab_shared | Avatar | Xie_JuQianAvatar |

Eight UnityFS bundles were decompressed and their Unity 2019.4 serialized object tables read. 28 objects of classes Mesh (43), AnimationClip (74), Avatar (90), Animator (95), and SkinnedMeshRenderer (137) were inventoried.

**Not yet verified:** Mesh vertex/triangle counts, skeletal bone hierarchies, or animation duration/keyframe content. Object names and serialized byte sizes are not proxies for these measurements.

## Titan Legends implications
- Keep scene/prefab data distinct from shared mesh/rig/animation bundles when analyzing references.
- Bosses may use multiple mesh objects; Titan Legends Wurzelkönig can use separately animated body and accessory components, designed independently.
- Animation effects may be separate from the main mesh; independently author boss telegraphs and effects.
- Validate on Android with the existing forest GLB workflow; do not assume Unity object metrics transfer directly to Godot.
