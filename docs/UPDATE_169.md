# Titan Legend – Update 169: GitHub workflow & combat regression tests

## Migration state
The repository previously contained only a README. Update 168's full Godot source is being migrated into GitHub. The project.godot configuration is tracked, but the scene/scripts/assets must be imported before the project can run. Do not claim the game is executable until Godot headless validation passes.

## Locked gameplay requirements
- Team of four; at most one active tank.
- First selected tank holds the slot; later tank choices are rejected, with no forced role changes.
- Exactly 1 tank + 2 DD + 1 healer activates team composition bonus.
- Only a living active tank may taunt or intercept group damage.
- No HP regeneration for tanks; no resurrection.
- Dodge must suppress HP loss and damage-number display.
- Boss-specific target selection must not be overwritten by normal enemy targeting.

## Regression test plan
1. Player A chooses tank; player B's tank selection fails. Player A remains tank.
2. Player A switches away from tank; player B can choose tank.
3. Tank dies: taunt no longer forces targeting and intercept ceases immediately.
4. Non-taunted ordinary enemy can target other living heroes.
5. Taunted ordinary enemy must target the active living tank.
6. Damage intercepted must never duplicate or become negative.
7. Dodge applies no HP damage and shows the dodge animation.
8. Repeated targets in one attack do not duplicate hits.
9. No automatic revival or tank regeneration.

## Validation
Not yet run in Godot or Android. Source import still in progress.
