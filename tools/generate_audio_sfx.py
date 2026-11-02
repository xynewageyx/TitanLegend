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
