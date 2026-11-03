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

## Vertiefung: Verzeichnisstruktur und Zuordnung (2026-11-03)
Die folgenden Beispiele wurden anhand des ausgelesenen Archivverzeichnisses überprüft; sie beweisen noch keine dekodierten Meshes oder Animationen.

| Referenzpfad im Archiv | Titan-Legends-Bereich | Konkrete nächste Untersuchung |
| --- | --- | --- |
| `assets/AssetBundles/Asset/assets/lib/character/base/` | Charaktere | Grundtypen und Klassen-/Variantenbezeichnungen inventarisieren |
| `assets/AssetBundles/Asset/assets/lib/character/element/` | Charaktere/Ausrüstung | Varianten und modulare Zuordnung prüfen |
| `assets/AssetBundles/Asset/assets/models/hero/base/shizhuang/` | Kostüme/Waffen | Outfit- und Waffenvarianten nach Dateipfaden erfassen |
| `assets/AssetBundles/Asset/assets/lib/monsters/` | Gegner/Bosse | Gegnerklassen und Benennungsschema kategorisieren |
| `assets/AssetBundles/Asset/assets/models/pet/` | Begleiter | Begleitertypen und Animationsgruppen inventarisieren |
| `assets/AssetBundles/Asset/assets/lib/scripts/main/skill/` | Skills | Gruppen für passive und auslösbare Skills prüfen |
| `assets/AssetBundles/Asset/assets/models/expression/animationclip_ab_list` | Animation | Referenzlisten und Rig-Zuordnung prüfen |
| `assets/AssetBundles/Asset/Music/` | Audio | Audio-Kategorien anhand der Dateinamen unterscheiden |

Zusätzlich nachgewiesene Pfadnamen: `models/hero/base/shizhuang/ss10_weapon/`, `models/hero/base/shizhuang/sz_zhangyu_hair/`, `lib/scripts/main/skill/passiveskill/` und `lib/scripts/main/skill/releaseskill/`.

**Priorisierte Arbeit:** (1) Klassen- und Haarvarianten, (2) Ausrüstungsslot-Mapping, (3) Animationsgruppen und Skeleton-Kompatibilität, (4) Gegner-/Begleiter-Typen, (5) mobile Material- und Performance-Budgets. Diese Reihenfolge ist ein Arbeitsplan, keine Behauptung bereits entschlüsselter Daten.

**Verbindlich:** Nur eigene oder eindeutig lizenzierte Spielassets übernehmen. Keine Unity-Originaldateien ins öffentliche Repository übertragen.

## Binärprüfung: echte UnityFS-Dateiköpfe (2026-11-03)
Vier ausgewählte Archivdateien wurden über libarchive **inhaltlich gelesen**. Alle vier beginnen mit `UnityFS\0`, nennen Formatversion `5.x.x` und Unity-Editorversion `2019.4.16f1c1`. Das ist eine echte Headerprüfung, **keine** Dekodierung der enthaltenen Prefab-/Animation-Objekte.

| Archivdatei | Bytes | SHA-256 |
| --- | ---: | --- |
| `lib/character/base/beryl.prefab_ab` | 3.657 | `024bc8352e2b82a2ac6d02c8eb500bedcf4314d389313224c9dfef7e2a3c04cf` |
| `lib/character/base/brook.prefab_ab` | 4.456 | `82c8ec260cc5d8b258a428d816c2265c28d339a09c4fc8df8e2858c8991b7ba7` |
| `lib/character/base/chad.prefab_ab` | 4.135 | `02a89fc55b7be567d581dce83b36e6e3190dd30f8a7b652ed7caed428ef13d77` |
| `models/expression/animationclip_ab_list` | 98.568 | `d09f7d46e3c1e81045f0decd862b9f38d4c3d70985618f6388a6103f82c552a5` |

**Nächster technischer Schritt:** Einen mit Unity 2019.4 kompatiblen Bundle-Parser in einer isolierten Analyseumgebung nutzen; Objektklassen, Transform-Hierarchien, Animator-/AnimationClip-Referenzen und Mesh-/Material-Metadaten inventarisieren. Keine Originalressourcen oder urheberrechtlich geschützten Assets im öffentlichen Repo ablegen.

### Präzisierte Teilmengen nach Verzeichnispfad
Die folgenden Zahlen zählen **nur Einträge mit Dateigröße > 0 innerhalb des exakt genannten Pfads**; sie sind nicht mit den breiten Stichwortzahlen oben vergleichbar:
- `lib/character/base/`: 122 Einträge, 17.285.758 Bytes
- `models/hero/base/shizhuang/`: 87 Einträge, 15.874.831 Bytes
- `lib/monsters/`: 157 Einträge, 13.462.638 Bytes
- `models/pet/`: 14 Einträge, 4.651.596 Bytes
- `lib/scripts/main/skill/`: 17 Einträge, 676.600 Bytes

## UnityFS-LZ4-Dekompression nachgewiesen (2026-11-03)
Die vier folgenden Referenzdateien wurden aus dem geteilten 7z-Archiv selektiv extrahiert. Ein isolierter Python-Parser hat die UnityFS-Header (Formatversion 7), die 16-Byte-Ausrichtung, die LZ4-komprimierten Blockinformationen, die Blockliste und den einzigen internen Dateieintrag pro Bundle verarbeitet. Die Blocknutzdaten wurden erfolgreich dekomprimiert; **das Unity SerializedFile-Objektmodell wurde noch nicht interpretiert**.

| UnityFS-Datei | Bundle-Bytes | LZ4-Blöcke | Entpackte Bytes | Interner Name | SHA-256 der entpackten Daten |
| --- | ---: | ---: | ---: | --- | --- |
| `lib/character/base/beryl.prefab_ab` | 3.657 | 1 | 9.492 | `CAB-66ddda5bddc5ca5f01d54b4871fca5d2` | `fa9f43acd8afa0f9` (Präfix) |
| `lib/character/base/brook.prefab_ab` | 4.456 | 1 | 13.180 | `CAB-cf94a32a8cdd9ae1982649060964e00d` | `cba0dadd946b816d` (Präfix) |
| `lib/character/base/beryl.prefab_ab_shared` | 142.249 | 3 | 281.191 | `CAB-2062281392ae861281b59ebda30e4835` | `6d2c46a1a2ba7731` (Präfix) |
| `models/expression/animationclip_ab_list` | 98.568 | 19 | 2.446.852 | `CAB-6c3de20da4523b0bc14cd7fc9b065e97` | `2d0d18dabc7e2e98` (Präfix) |

Die Prüfsummen in dieser Tabelle sind ausdrücklich **16-stellige Präfixe**, nicht vollständige SHA-256-Hashes.

**Nächste Schritte für die zuständigen Bereiche:** Unity SerializedFile-Header und TypeTree prüfen, danach lediglich Struktur-Metadaten (Objektklassen, Referenzen, Skeleton-/Clip-Zuordnung) dokumentieren. Proprietäre Original-Meshes, Animationen, Sounds und Texturen nicht in Titan Legends oder das öffentliche GitHub-Repository übernehmen.

## Unity SerializedFile-Metadaten (2026-11-03)
Die dekomprimierten Payloads der vier Stichproben wurden bis zum Anfang ihrer SerializedFile-Type-Tabellen interpretiert. Alle vier melden `SerializedFile format_version=21`, `Unity version=2019.4.16f1c1`, `target_platform=13` und `enableTypeTree=true`.

| Datei | Typdefinitionen | Metadatenbytes | Datenoffset |
| --- | ---: | ---: | ---: |
| `beryl.prefab_ab` | 5 | 8.109 | 8.144 |
| `brook.prefab_ab` | 7 | 10.905 | 10.928 |
| `beryl.prefab_ab_shared` | 8 | 30.489 | 30.512 |
| `animationclip_ab_list` | 2 | 37.181 | 37.216 |

**Interpretationsgrenze:** Die Typdefinitionen sind noch keine gezählten Objekte, Skelette oder Animationsclips. Die konkrete Class-ID-Tabelle, Objektliste und die referenzierten Daten wurden noch nicht vollständig gelesen. `UnityPy` ließ sich in der isolierten Umgebung wegen fehlender Paketnetzverbindung nicht installieren; ein kleiner eigener Parser bestätigte die oben aufgeführten Headerfelder. Nächster Schritt ist eine robuste Class-ID-/Objekttabellen-Auswertung mit Testdateien und klaren Fehlergrenzen.
