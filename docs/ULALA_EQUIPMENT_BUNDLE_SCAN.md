# Additional equipment UnityFS scan (2026-11-03)

Fifteen distinct local equipment bundles were successfully decompressed and their SerializedFile headers checked. These are original third-party reference bundles; **only metadata is documented here**, not redistributed assets.

| Equipment family | Number of inspected bundles |
| --- | ---: |
| Hair | 5 |
| Clothes | 2 |
| Shoes | 2 |
| Weapon | 3 |
| Subweapon | 2 |
| Bracers | 1 |
| **Total** | **15** |

Inspected file names:

- `ck_chushi_hair.prefab_ab`, `ck_chushi_hair.prefab_ab_shared`
- `ck_dujiaoxing_clothes.prefab_ab`, `ck_dujiaoxing_clothes.prefab_ab_shared`
- `ck_dujiaoxing_hair.prefab_ab`, `ck_dujiaoxing_hair.prefab_ab_shared`
- `ck_dujiaoxing_shoes.prefab_ab`, `ck_dujiaoxing_shoes.prefab_ab_shared`
- `ck_dujiaoxing_subweapon.prefab_ab`, `ck_dujiaoxing_weapon.prefab_ab`
- `ck_lang_hair.prefab_ab`, `ck_lang_subweapon.prefab_ab`, `ck_lang_weapon.prefab_ab`
- `dly_dajiaolu_weapon.prefab_ab`, `dly_pugongying_bracers.prefab_ab`

All 15 files are UnityFS bundles containing Unity SerializedFile version **21**. The count of TypeTree type declarations ranges from **5 to 7**. This scan confirms successful block decompression and readable headers; it does **not** yet identify attachment bones, mesh contents, material properties, or compatibility with the game's own character rig.

Next: parse object directories and PPtr references, compare each main bundle to its `_shared` counterpart, and record only high-level structural insights. Do not copy the original meshes, textures, rigs, animations, or other proprietary content into Titan Legends.
