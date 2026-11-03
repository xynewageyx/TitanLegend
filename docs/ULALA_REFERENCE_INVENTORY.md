# Ulala-Referenzarchiv: überprüftes Inhaltsinventar (2026-11-03)

Quelle: vom Projektinhaber verlinkter Google-Drive-Ordner `1exzf9zslKN4U0jPu41Ay-gwkcSBTP0oo`.
Neun Teile `ulala_backup.7z.001` bis `.009` erfolgreich geladen und zusammengesetzt. Gesamtgröße der komprimierten Teile: **1.933.245.476 Bytes**.
7z-Verzeichnis über libarchive gelesen: **27.270 Einträge**, davon **25.546 Einträge mit Dateigröße > 0**. Diese Zahl ist nicht zwingend identisch mit der tatsächlichen Anzahl regulärer Dateien (leere Dateien möglich).

## Häufigste Dateiendungen
- `.txt_ab`: 14.872
- `.prefab_ab`: 4.270
- `.prefab_ab_shared`: 1.628
- `.png_ab`: 1.472
- `.mat_ab_shared`: 1.437
- Ohne Endung: 1.308
- `.spriteatlas_ab`: 174
- `.overridecontroller_ab`: 99
- `.anim_ab`: 88

## Auffällige Inhalte
- Großes OBB `main.344.com.xdg.and.wll.obb` mit ca. **1.280,8 MiB** unkomprimierter Eintragsgröße.
- AssetBundles unter `assets/AssetBundles/Asset/assets/` mit vielen Charakter-, Skill-, Waffen-, Haustier- und UI-Ressourcen.
- Nach **Dateipfadnamen** (nicht inhaltlich geprüft) grob: `character` 3.642 Einträge; `monster` 712; `skill` 1.209; `weapon` 668; `pet` 1.306; `ui` 5.017.
- Audio unter `assets/AssetBundles/Asset/Music/` (u. a. `.acb` und `.awb`).
- `bin/Data/Managed/` enthält u. a. `.pdb`-Dateien.
- Unity-AssetBundle-Endungen deuten auf Unity-Content hin, **nicht** auf direkt in Godot nutzbare 3D-Modelle.

## Arbeitsaufträge für Titan-Legends-Bereiche
- **Charaktere:** Namen, Varianten und Materialorganisation als Referenz kategorisieren; eigene Chibi-Modelle/Rigs erstellen.
- **Gegner/Bosse:** Monster-Typen und Silhouetten inventarisieren; eigene Meshes/Animationen entwerfen.
- **Skills/VFX:** Skill- und Effektgruppen erfassen, eigene Godot-Partikeleffekte bauen.
- **Waffen/Rüstung:** vorhandene Kategorien und Slot-Varianten als Designreferenz nutzen; eigene Assets produzieren.
- **UI:** Struktur, Icons, Atlanten und Lesbarkeit auf Android analysieren; eigene UI gestalten.
- **Audio:** Soundkategorien dokumentieren; keine fremden Audio-Dateien ins Spiel kopieren.
- **Integration:** Godot 4.7.2 / Android, Performance, Ressourcengrößen und Lizenzgrenzen beachten.

## Grenzen und nächste Prüfungen
- Bisher **7z-Dateiverzeichnis und Dateinamen** analysiert; keine vollständige inhaltliche Dekodierung der Unity-AssetBundles, Meshes, Rigs, Animationen, Texturen oder OBB.
- Archive und urheberrechtlich geschützte Originaldateien werden **nicht** ins öffentliche TitanLegend-Repository hochgeladen.
- Keine automatische Live-Benachrichtigung anderer Chat-Unterhaltungen. Andere Bereiche können dieses Inventar über GitHub lesen.
