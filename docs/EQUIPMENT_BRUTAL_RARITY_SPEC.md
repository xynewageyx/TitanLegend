# Titan Legends — Equipment rarity silhouette specification

Status: proposed design specification; no production meshes are implied.

## Non-negotiable visual direction
Keep the original, friendly, exaggerated chibi 3D proportions inspired by the *genre* of Ulala. Do not copy proprietary assets. With every rarity increase, **both weapons and armor become visibly more brutal, intimidating and imposing**. Color-only rarity swaps do not meet this requirement. Brutality means dramatic fantasy shapes, not photorealistic gore.

| Rarity index | Name | Weapon silhouette | Armor silhouette | Optional FX |
| --- | --- | --- | --- | --- |
| 0 | Common / white | Compact, plain and readable | Basic leather/iron | None |
| 1 | Uncommon / green | Wider blade or heavier head, one reinforced feature | Layered plates and trim | Small green accent |
| 2 | Rare / blue | Distinct hooked edge or angular head, crystal | Pronounced shoulder and helmet forms | Blue rune glow |
| 3 | Epic / yellow | Massive jagged blade/head, blunt cartoon spikes | Horned helmet, spiked pauldrons, layered plates | Golden runes |
| 4 | Legendary / orange | Oversized dragon/skull motif, aggressive teeth, split blade | Heavy horned skull/dragon motifs, sharp silhouette | Fire core and sparks |
| 5 | Mythic / purple | Monumental demonic fantasy outline, floating blade segments | Towering horns, skull ornaments, floating plates | Violet energy, hovering shards |

## Class-specific readability
All 11 classes must follow the same progression while retaining their recognizable weapon language and body silhouette: warrior, paladin, rogue, hunter, mage, priest, shaman, druid, warlock, summoner and brawler. Keep healer and caster weapons menacing at higher rarity without making every class wield the same sword.

## Attachment and rigging integration
- Existing Godot script `scripts/equipment/hero_equipment_sockets.gd` expects hand sockets and 13 named armor sockets; verify actual marker availability on each character before mounting.
- Existing preview scripts are prototypes, not final rigged meshes. Use original glTF/GLB assets and skinning as needed.
- Ulala metadata study in `docs/ULALA_CHARACTER_HIERARCHIES.md` confirms named weapon/clothing objects in selected Unity prefabs, but **does not establish** Godot skeleton compatibility, complete bone hierarchy, or skin weights.
- Preserve animations and check clipping during idle, walk, attack, cast, and victory; ensure oversized weapons do not obscure the face or the other team members.

## Mobile quality tiers
Maintain silhouette on all quality settings. Reduce particle counts, glow, and floating component animation on Low; do not remove the shape-defining horns or blade geometry. Prefer compact meshes and material reuse. Test portrait visibility at 720x1280.

## Acceptance checklist
- [ ] Six tiers have clearly distinct silhouettes in grayscale.
- [ ] Each successive tier reads as more dangerous than the previous one.
- [ ] All 11 classes remain recognizable.
- [ ] Weapons attach correctly to hands; armor follows the appropriate animated bones/markers.
- [ ] No obvious clipping in common combat animations.
- [ ] Low graphics mode preserves the silhouette.
- [ ] No third-party proprietary models/textures are imported.
