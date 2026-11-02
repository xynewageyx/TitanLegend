#!/usr/bin/env python3
"""Generate original lightweight placeholder SFX; no third-party dependencies."""
import math, random, struct, wave
from pathlib import Path
RATE = 22050
SOUNDS = {
 "ui/click.wav": (0.075, 650, 1050, "tone"),
 "ui/reward.wav": (0.45, 480, 1100, "tone"),
 "combat/hit.wav": (0.18, 140, 55, "noise"),
 "combat/critical.wav": (0.32, 340, 70, "noise"),
 "combat/dodge.wav": (0.22, 900, 240, "noise"),
 "combat/interrupt.wav": (0.38, 760, 120, "tone"),
 "combat/boss_warning.wav": (0.65, 120, 55, "tone"),
 "skills/heal.wav": (0.60, 420, 920, "tone"),
 "skills/fire.wav": (0.45, 240, 80, "noise"),
 "skills/ice.wav": (0.50, 1050, 320, "tone"),
 "skills/shadow.wav": (0.55, 260, 65, "tone"),
}
SOUNDS.update({
 "classes/warrior_attack.wav": (0.150, 180, 75, "noise"),
 "classes/paladin_attack.wav": (0.168, 263, 124, "tone"),
 "classes/druid_attack.wav": (0.186, 346, 173, "tone"),
 "classes/shaman_attack.wav": (0.204, 429, 222, "tone"),
 "classes/hunter_attack.wav": (0.222, 512, 271, "noise"),
 "classes/rogue_attack.wav": (0.240, 595, 320, "noise"),
 "classes/mage_attack.wav": (0.258, 678, 369, "tone"),
 "classes/warlock_attack.wav": (0.276, 761, 418, "tone"),
 "classes/summoner_attack.wav": (0.294, 844, 467, "tone"),
 "classes/priest_attack.wav": (0.312, 927, 516, "tone"),
 "classes/brawler_attack.wav": (0.330, 1010, 565, "noise"),
})
SOUNDS.update({
 "classes/warrior_skill.wav": (0.300, 330, 700, "noise"),
 "classes/paladin_skill.wav": (0.323, 397, 752, "tone"),
 "classes/druid_skill.wav": (0.346, 464, 804, "tone"),
 "classes/shaman_skill.wav": (0.369, 531, 856, "tone"),
 "classes/hunter_skill.wav": (0.392, 598, 908, "noise"),
 "classes/rogue_skill.wav": (0.415, 665, 960, "noise"),
 "classes/mage_skill.wav": (0.438, 732, 1012, "tone"),
 "classes/warlock_skill.wav": (0.461, 799, 1064, "tone"),
 "classes/summoner_skill.wav": (0.484, 866, 1116, "tone"),
 "classes/priest_skill.wav": (0.507, 933, 1168, "tone"),
 "classes/brawler_skill.wav": (0.530, 1000, 1220, "noise"),
})
SOUNDS.update({
 "skills/taunt.wav": (0.32, 170, 320, "noise"),
 "skills/guard.wav": (0.48, 260, 120, "tone"),
 "skills/interrupt.wav": (0.25, 1100, 180, "noise"),
 "skills/regeneration.wav": (0.72, 360, 880, "tone"),
})
SOUNDS.update({
 "elements/fire.wav": (0.47, 270, 85, "noise"),
 "elements/ice.wav": (0.54, 1280, 380, "tone"),
 "elements/nature.wav": (0.63, 280, 790, "tone"),
 "elements/shadow.wav": (0.58, 190, 62, "tone"),
 "elements/light.wav": (0.49, 680, 1350, "tone"),
})
SOUNDS.update({
 "elements/crystal.wav": (0.48, 1420, 760, "tone"),
 "elements/earth.wav": (0.65, 135, 48, "noise"),
 "elements/wind.wav": (0.73, 820, 180, "noise"),
 "elements/frost.wav": (0.59, 1180, 170, "tone"),
 "elements/lightning.wav": (0.24, 1750, 110, "noise"),
 "elements/chaos.wav": (0.82, 480, 55, "noise"),
})
SOUNDS["elements/water.wav"] = (0.68, 540, 165, "noise")
# Short, lightweight ambience beds loop in Godot; these remain placeholder audio.
SOUNDS.update({
 "ambient/fire.wav": (2.0, 110, 80, "noise"),
 "ambient/water.wav": (2.0, 149, 106, "tone"),
 "ambient/earth.wav": (2.0, 188, 132, "tone"),
 "ambient/nature.wav": (2.0, 227, 158, "noise"),
 "ambient/light.wav": (2.0, 266, 184, "tone"),
 "ambient/shadow.wav": (2.0, 305, 210, "tone"),
 "ambient/wind.wav": (2.0, 344, 236, "noise"),
 "ambient/frost.wav": (2.0, 383, 262, "tone"),
 "ambient/lightning.wav": (2.0, 422, 288, "tone"),
 "ambient/chaos.wav": (2.0, 461, 314, "noise"),
})
SOUNDS.update({
 "boss/fire.wav": (0.550, 140, 45, "noise"),
 "boss/water.wav": (0.585, 203, 64, "tone"),
 "boss/earth.wav": (0.620, 266, 83, "noise"),
 "boss/nature.wav": (0.655, 329, 102, "tone"),
 "boss/light.wav": (0.690, 392, 121, "noise"),
 "boss/shadow.wav": (0.725, 455, 140, "tone"),
 "boss/wind.wav": (0.760, 518, 159, "noise"),
 "boss/frost.wav": (0.795, 581, 178, "tone"),
 "boss/lightning.wav": (0.830, 644, 197, "noise"),
 "boss/chaos.wav": (0.865, 707, 216, "tone"),
})
def render(path, duration, start, end, mode):
 rng = random.Random(path)
 frames = bytearray()
 phase = 0.0
 total = int(RATE * duration)
 for i in range(total):
  t = i / max(1, total - 1)
  freq = start + (end - start) * t
  phase += 2 * math.pi * freq / RATE
  env = min(1.0, t * 30) * (1 - t) ** 2
  wave_value = math.sin(phase) * (0.8 if mode == "tone" else 0.3)
  if mode == "noise":
   wave_value += rng.uniform(-1, 1) * 0.65
  sample = int(max(-1, min(1, wave_value * env * 0.65)) * 32767)
  frames.extend(struct.pack("<h", sample))
 target = Path("assets/audio") / path
 target.parent.mkdir(parents=True, exist_ok=True)
 with wave.open(str(target), "wb") as out:
  out.setnchannels(1)
  out.setsampwidth(2)
  out.setframerate(RATE)
  out.writeframes(frames)
for path, parameters in SOUNDS.items():
 render(path, *parameters)
print(f"Generated {len(SOUNDS)} original placeholder sound effects.")
