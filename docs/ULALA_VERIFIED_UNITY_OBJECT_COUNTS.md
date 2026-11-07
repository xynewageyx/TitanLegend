# Ulala-Referenz: tatsächlich dekodierte Unity-Objekttabellen (2026-11-06)

Quelle: vom Nutzer bereitgestelltes neun-teiliges 7z-Backup. Acht gezielt extrahierte UnityFS-Bundles wurden lokal mit LZ4 und einem read-only Parser für Unity SerializedFile Version 21 ausgewertet. Die Zählungen stammen aus **Objekttabellen**, nicht aus Dateinamen oder Typdefinitionen.

| Bundle | Unity-Objekte | Mesh (43) | AnimationClip (74) | SkinnedMeshRenderer (137) | Animator (95) |
|---|---:|---:|---:|---:|---:|
| daduwa_yulin.prefab_ab | 9 | 0 | 0 | 1 | 1 |
| daduwa_yulin.prefab_ab_shared | 12 | 1 | 0 | 1 | 1 |
| guiboss.prefab_ab_shared | 14 | 1 | 0 | 1 | 1 |
| dujiaoxingboss_bai.prefab_ab | 14 | 0 | 0 | 2 | 1 |
| teshu_dujiaoxingboss.prefab_ab_shared | 6 | 0 | 1 | 0 | 0 |
| dujiaoxingboss.prefab_ab_shared | 18 | 2 | 0 | 2 | 1 |
| teshu_guiboss.prefab_ab_shared | 10 | 1 | 0 | 1 | 1 |
| danxiaozhu_conglin.prefab_ab_shared | 69 | 1 | 0 | 1 | 1 |

Hinweise:
- Ein Bundle ohne AnimationClip kann über andere Bundles referenzierte Clips verwenden.
- Mesh-/SkinnedMeshRenderer-Objektzahlen sind keine Polygon- oder Knochenzahlen.
- Der Parser hat UnityFS-LZ4-Datenblöcke, SerializedFile-Header, Typmetadaten und Objekttabellen gelesen. Mesh-Vertexdaten, Animation-Keyframes, Knochenhierarchien und Materialtexturen sind **noch nicht** inhaltlich dekodiert.
- Original-Assets werden nicht in Titan Legends übernommen. Ziel ist die technische Referenzanalyse für eigenständige Waldgegner.

Nächster Schritt: Object-Byte-Ranges und Typbaumfelder für Mesh, SkinnedMeshRenderer und AnimationClip sicher lesen, Querverweise über CAB-Dateien auflösen und anschließend nur aggregierte technische Messwerte dokumentieren.
