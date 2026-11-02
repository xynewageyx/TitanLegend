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
  # Layer subtle class-specific harmonics and percussive transients so attacks
  # and abilities sound less alike without adding files or dependencies.
  if path.startswith("classes/"):
   class_name = path.split("/")[1].split("_")[0]
   is_skill = path.endswith("_skill.wav")
   character = {
    "warrior": (0.42, 1.25), "paladin": (0.30, 2.0),
    "druid": (0.18, 1.5), "shaman": (0.26, 2.5),
    "hunter": (0.38, 3.0), "rogue": (0.48, 4.0),
    "mage": (0.32, 2.8), "warlock": (0.36, 1.35),
    "summoner": (0.22, 1.8), "priest": (0.20, 2.2),
    "brawler": (0.52, 1.15),
   }
   strength, harmonic = character.get(class_name, (0.2, 2.0))
   wave_value += math.sin(phase * harmonic) * strength * (0.65 if is_skill else 1.0)
   if class_name in ("warrior", "hunter", "rogue", "brawler"):
    wave_value += rng.uniform(-1, 1) * strength * math.exp(-25 * t)
   if is_skill:
    wave_value += math.sin(phase * 0.5) * 0.16 * math.sin(math.pi * t)
  # Boss elements need distinct warning/release timbres, not just pitch changes.
  if path.startswith("boss/"):
   element = path.split("/")[1].split(".")[0]
   # Each element uses a different mix of pulsing, harmonics and transients.
   signatures = {
    "fire": (2.3, 0.42, 11), "water": (1.4, 0.18, 3),
    "earth": (0.7, 0.55, 6), "nature": (1.7, 0.20, 4),
    "light": (3.1, 0.22, 9), "shadow": (0.5, 0.38, 5),
    "wind": (2.7, 0.48, 14), "frost": (3.8, 0.15, 7),
    "lightning": (4.5, 0.60, 23), "chaos": (1.13, 0.57, 17),
   }
   harmonic, texture, pulses = signatures.get(element, (2.0, 0.2, 5))
   wave_value += math.sin(phase * harmonic) * 0.38
   wave_value += rng.uniform(-1, 1) * texture * (0.5 + 0.5 * math.sin(2 * math.pi * pulses * t) ** 2)
   if element in ("earth", "lightning", "fire", "chaos"):
    wave_value += rng.uniform(-1, 1) * 0.38 * math.exp(-32 * t)
  if path.startswith("ambient/"):
   # Seamless periodic atmosphere with distinct layers per biome.
   # Integer cycle counts guarantee matching endpoints on repeated playback.
   biome = path.split("/")[1].split(".")[0]
   profiles = {
    "fire": (9, 23, 0.42), "water": (5, 13, 0.18),
    "earth": (4, 11, 0.30), "nature": (7, 19, 0.15),
    "light": (12, 29, 0.08), "shadow": (3, 17, 0.25),
    "wind": (6, 31, 0.35), "frost": (11, 37, 0.10),
    "lightning": (14, 43, 0.32), "chaos": (8, 47, 0.40),
   }
   low_cycles, high_cycles, grit = profiles.get(biome, (7, 19, 0.2))
   angle = 2 * math.pi * i / total
   low = math.sin(angle * low_cycles) * 0.42
   high = math.sin(angle * high_cycles) * 0.17
   breath = 0.75 + 0.25 * math.sin(angle * 2)
   # Harmonic texture stays loopable and avoids discontinuous random noise.
   texture = math.sin(angle * (high_cycles + low_cycles)) * grit
   wave_value = (low + high + texture) * breath
   env = 1.0
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
