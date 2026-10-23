# Titan Legends – Update 186: Überlappende Heilungen im Bosskampf

## Codeprüfung und Fehler
In `battle_manager.gd` ersetzte `_apply_heal_over_time()` eine bestehende HoT vollständig. Eine schwächere zweite Erneuerung konnte so die zuvor stärkere Heilung überschreiben, besonders wenn mehrere Heiler (Druide, Schamane, Priester, Paladin) oder vorbereitete Heilungen gleichzeitig vorhanden waren.

## Korrektur
- Die neue Heilung über Zeit wird wie bisher aus Heldengesundheit, Klassenprofil, Talentbonus und Skillstärke berechnet.
- Ist bereits eine HoT aktiv, gilt für den Tickbetrag jetzt **Maximum aus vorhandener und neuer HoT-Stärke**.
- Für die Restlaufzeit gilt ebenfalls **Maximum aus bisher verbleibenden und neuen Ticks**.
- Es wird nicht beliebig addiert oder gestapelt. Dadurch entstehen keine unbegrenzten Heilungsspitzen.
- Tote Ziele werden weiterhin nicht wiederbelebt. Vorbereitete Heilungen werden nach Benutzung einmalig aus dem Speicher entfernt.

## Unveränderte Regeln
- Boss-Zeitlimit: **60 Sekunden**.
- Strikte Skillfolge: 1 → 2 → 3 → 4.
- Tank, Heiler und DD bleiben getrennte Rollen; ein aktiver Tank pro Team.
- Bosse eines Gebiets besitzen dasselbe Element und vier wiederkehrende Varianten.
- Midgame beginnt mit Gebiet 5 (Stage 401).

## Prüfung und Grenzen
Die Änderung wurde in GitHub gespeichert und ein statischer Regressionstest ergänzt. Der Test kontrolliert, dass stärkere Tickwerte und längere Restlaufzeiten beim Überschreiben einer bestehenden HoT erhalten bleiben.

**Nicht durchgeführt:** Godot-4.7-Laufzeittest, Android-Build oder vollständige numerische Simulation von zwölf Gebieten. Eine Aussage über neue Siegquoten lässt sich daraus nicht ableiten.

Für eine vollständige Prüfung müssen echte Kämpfe mit zwei Heilern, vorbereiteten HoTs, Flächenangriffen und einem 60-Sekunden-Bosszeitlimit in Godot gestartet werden.
