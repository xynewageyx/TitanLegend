# Visual equipment QA — actual Godot OpenGL screenshots, 2026-11-10

## Primary evidence
- Successful CI run: https://github.com/xynewageyx/TitanLegend/actions/runs/42760356033
- GitHub Actions artifact: `TitanLegends-Rarity-Silhouette-V2-Visual-QA` (artifact ID `13737223416`)
- Confirmed ZIP contents: **64 individual 720×1280 PNG screenshots + four 4×3 contact sheets + one manifest JSON**, total 68 PNGs.
- `manifest.json` confirms 12 character classes; 12 front idle, 12 front attack, 12 front walk, 12 front dodge, 12 side attack, plus two rarity-0 and two rarity-3 previews.
- Rendered on Linux GitHub Actions using Godot 4.7.2 with xvfb/Mesa; **not** an actual Android phone.

## Independent frame-difference audit

Compared corresponding original full-resolution front PNGs as 8-bit RGB. A pixel is "different" if the maximum absolute difference in at least one color channel is **greater than 18/255**. Percentage is different pixels divided by all pixels. Background, pose, camera reframing and effects all contribute, so these values **cannot be interpreted as bone animation amplitude, weapon collision percentages or retargeting quality**.

See [per-class measurements](TITAN_2026_11_10_VISUAL_FRAME_DIFFERENCES.csv).

- Standard-class attack-versus-walk differences: **11.86%–22.76%** of pixels.
- Death Knight attack-versus-walk difference: **6.67%**, smaller than every standard class.
- Death Knight walk-versus-dodge difference: **11.84%**; standard class range: **23.28%–30.75%**.
- No compared action-image pair was identical. The screenshots visibly differ, but this alone is not proof the intended anatomical joints move correctly.

## Visual observations

Review of front-attack, front-walk, front-dodge and side-attack contact sheets:
- The 12 stylized characters and colored equipment render without blank frames.
- Large bright circular front-mounted elements obscure significant portions of the torso in several classes. This may be intentional weapon/shield/focus art, not necessarily skin intersection.
- The Death Knight has a very large dark rear silhouette and a strong purple circular foreground element. His pose/action differences are comparatively subtle in the available screenshot samples.
- From the side views, the large equipment outlines and forearm-area attachments are visible. The contact sheets are too small to certify individual fingertip clearance or fine mesh intersection.
- Since the eleven standard rigs use `Arm_R` rather than a separate `Hand_R` joint, a technically correct attachment can still have imperfect visual wrist/finger alignment.

## Verified / not verified

**Verified:** CI rendered and uploaded all 68 intended PNGs; manifest class/pose coverage; all previously completed 144 grip-to-socket continuity samples; image-to-image differences.

**Not verified:** physical Android frame rate or GPU compatibility, absence of collision/clipping, readable combat silhouettes at gameplay zoom, finger-level grip alignment, any transfer of Ulala animations.

## Follow-up priorities

1. Review larger individual front/side screenshots of Death Knight and all weapon classes at gameplay camera zoom, rather than relying only on contact sheets.
2. Add close-up screenshots of right-hand grip and silhouette for each original class's own procedural weapon; consider hand-offset adjustments on standard 8-bone rigs.
3. Test high-rarity weapon silhouettes at three camera distances and with a 4-character formation, including overlaps with pets and VFX.
4. Keep Unity reference metadata separate and do not import original Ulala animation/rig assets.
