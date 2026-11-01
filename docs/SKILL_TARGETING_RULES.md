# Titan Legends – Verbindliche Skill-Eigenschaften (01.11.2026)

## Grundregel
Der Spieler rüstet pro Held maximal vier aktive Skills aus. Im automatischen Kampf werden ausschließlich diese ausgerüsteten Skills ausgeführt. Die Auto-KI wählt Zeitpunkt und gültiges Ziel nach Priorität, Aufladung, Cooldown und Zielbedingungen; sie erfindet keine Angriffe oder Effekte.

## Datengetriebene Wirkungen
- `target_mode=single_enemy`: trifft ausschließlich ein gültiges Ziel.
- `target_mode=enemy_area`: trifft Gegner im definierten Radius/Bereich.
- `target_mode=single_ally` oder `ally_area`: Heilung/Schutz entsprechend Zieltyp.
- `effects`: Liste expliziter Effekte wie damage, heal, shield, interrupt, control, buff.
- AoE wird ausschließlich durch die Skilldefinition bestimmt, nicht durch Gegneranzahl oder KI.
- Ein Skill darf mehrere explizite Effekte kombinieren (z.B. AoE + interrupt).
- Unterbrechung erfolgt ausschließlich bei erfolgreichem Einsatz eines Skills mit interrupt-Effekt gegen einen unterbrechbaren Cast.
- Keine separaten automatischen Basisangriffe ohne eigene ausgerüstete Skilldefinition.
- Die bestehende Skillreihenfolge ist die Ausführungspriorität; kontextabhängige Regeln dürfen nur zwischen tatsächlich ausgerüsteten, verfügbaren Skills wählen.

## Umsetzung
Skilldaten, Trefferlogik, Animationsereignisse und visuelle Effekte müssen dieselbe Skilldefinition referenzieren. Keine Änderung der Spielregeln durch VFX.
