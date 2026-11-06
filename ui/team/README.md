# Titan Legends – Team HUD v2

Godot 4.x, eigenständige Teamkacheln im Ulala-inspirierten Stil (keine kopierten Assets).

- `titan_team_hud.tscn`: 4 Slots, auf schmalen Displays 2×2, sonst 4 Spalten.
- `titan_team_card.tscn`: Name, Level, Rolle, HP, Teamführer und Auswahl.
- Die Oberfläche wird **noch nicht** automatisch mit GameManager/BattleManager verbunden.
- Zur Einbindung die HUD-Szene in eine passende Kampfszene instanziieren und `update_team(Array[Dictionary])` aufrufen.
- Dictionary-Felder: `name`, `level`, `role`, `hp_ratio` (0–1), `leader`, `occupied`.
- `hero_selected(index)` wird bei Auswahl ausgelöst.
- Validierung über GitHub Actions/Android steht noch aus.
