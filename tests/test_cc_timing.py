"""Deterministic approximation of fixed-skill CC timing (not a Godot runtime test).
Run: python -m unittest discover -s tests -p 'test_cc_timing.py' -v
"""
import unittest

ATTACK_INTERVAL = [1.25, 0.75, 0.75, 1.50]
DEFAULT_LOADOUT = [0, 1, 2, 7]
SKILL_COST = {0: 2, 1: 3, 2: 4, 3: 2, 7: 4}


def cast_ticks(required_cc):
    return 3 + max(0, required_cc - 1) * 2


def simulate(required_cc, cast_start, cc_heroes=4):
    """Fixed 1->2->3->4 sequence; normal attacks charge the next slot.
    Ignores actual enemy damage/HP, support healing conditions and frame jitter.
    """
    cast_end = cast_start + 2.2 * cast_ticks(required_cc)
    timers = [0.0] * 4
    charges = [0] * 4
    slots = [0] * 4
    loadouts = [DEFAULT_LOADOUT if i < cc_heroes else [0, 1, 2, 3] for i in range(4)]
    hits = []
    t = 0.0
    while t < min(60.0, cast_end):
        t = round(t + 0.05, 3)
        for i in range(4):
            timers[i] += 0.05
            if timers[i] + 1e-7 < ATTACK_INTERVAL[i]:
                continue
            timers[i] -= ATTACK_INTERVAL[i]
            charges[i] += 1
            choice = loadouts[i][slots[i]]
            cost = SKILL_COST[choice]
            if charges[i] < cost:
                continue
            charges[i] = 0
            slots[i] = (slots[i] + 1) % 4
            if choice == 7 and cast_start <= t < cast_end:
                hits.append((t, i))
                if len(hits) >= required_cc:
                    return True, hits
    return False, hits


class BossInterruptTimingTests(unittest.TestCase):
    def test_cast_windows(self):
        self.assertEqual([cast_ticks(n) for n in (1, 2, 3)], [3, 5, 7])

    def test_more_than_one_cc_requires_multiple_hits(self):
        phases = [4.4 + 2.2 * k for k in range(18)]
        self.assertTrue(all(not simulate(2, t, 1)[0] for t in phases))
        self.assertTrue(all(not simulate(3, t, 1)[0] for t in phases))

    def test_three_cc_possible_with_three_or_four_heroes(self):
        phases = [4.4 + 2.2 * k for k in range(18)]
        self.assertGreaterEqual(sum(simulate(3, t, 3)[0] for t in phases), 15)
        self.assertEqual(sum(simulate(3, t, 4)[0] for t in phases), 18)

    def test_one_cc_is_phase_sensitive(self):
        phases = [4.4 + 2.2 * k for k in range(18)]
        wins = sum(simulate(1, t, 1)[0] for t in phases)
        self.assertLess(wins, len(phases))
        self.assertGreater(wins, 0)


if __name__ == "__main__":
    unittest.main()
