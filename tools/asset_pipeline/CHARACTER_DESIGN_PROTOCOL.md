# Titan Legends – Character design consistency protocol

Reference methodology: https://github.com/khanhhuyenngo985-sys/character-scene-design-skills (MIT, review upstream LICENSE before copying any code).

This is an original Titan Legends design protocol, **not** a vendored copy of the upstream skill or an automated 3D model generator.

## Locked design attributes (per hero)
- Original stylized fantasy 3D chibi aesthetic; no copied Ulala models, characters, outfits, or textures.
- Unique readable silhouette at portrait-phone size.
- Proportion lock: head/body ratio, shoulder width, leg length, overall scale.
- Face anchors: eye spacing, nose, hair silhouette, permanent features.
- Outfit anchors: armor layers, gloves, boots, material palette, class symbol.
- Signature weapon and accessory anchors; exact hand grip and attachment point.
- Three-view turnaround: front, left/right side, back, neutral A-pose.
- Expression sheet: neutral, happy, angry, hurt, determined.
- Animation-ready rig targets: idle, walk, attack, cast, hit, dodge.
- Godot import target: .glb with humanoid skeleton, materials and named animation clips.

## Quality gates
1. Front, side and back show the *same* physical hero.
2. Costume and expressions preserve proportions, facial identity and weapon geometry.
3. No floating armor or clipping in idle/walk/attack preview.
4. Silhouette and class role remain readable on Android portrait screens.
5. Asset sources and licensing documented in asset manifest.
6. GLB file, rig, materials, animations and Godot runtime must be verified separately.

## Project integration notes
The existing Python `character_creator.py` currently produces JSON hero **specifications only**, not meshes.
Its class list is a preliminary tool list and must be reconciled with the current Godot gameplay class definitions before generating production assets.
Do not change gameplay classes or delete existing character assets based on this protocol.
AI-Character-Forge is not included: it requires model weights, training compute and dataset/license review.
