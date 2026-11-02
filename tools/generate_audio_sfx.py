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
