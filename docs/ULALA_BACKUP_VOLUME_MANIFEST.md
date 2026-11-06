# Ulala backup volume manifest (Drive metadata only)

Verified through direct Google Drive folder listing on 2026-11-06:
Folder: https://drive.google.com/drive/folders/1exzf9zslKN4U0jPu41Ay-gwkcSBTP0oo

| Volume | Size (bytes) | Drive file ID |
|---|---:|---|
| ulala_backup.7z.001 | 241172480 | 1T5pA0-btdgP9_HiboJ9DKNo91-e2GBby |
| ulala_backup.7z.002 | 241172480 | 1ryL0Q-sm_L4Gk1_n6_qqnetoQ3IAxRYw |
| ulala_backup.7z.003 | 241172480 | 1jiza-Ow5GQ4P7A74l3YJObsyCkqxMSTe |
| ulala_backup.7z.004 | 241172480 | 1jjg5bQapvBspxhLWyFpiDCTSZErhMIWT |
| ulala_backup.7z.005 | 241172480 | 18LxcAogNW8pLN9LA46jsQdKdDN2p00E_ |
| ulala_backup.7z.006 | 241172480 | 1LtibCi0kzHF6N1VeEQ6x-FQtVfznHt_w |
| ulala_backup.7z.007 | 241172480 | 1i5-qB-tM-8vy51Wa_beG4whQ5Gv_C0Eo |
| ulala_backup.7z.008 | 241172480 | 1F0Zm5hTvjqMDgW-pPeaUy5WguD_JsvuQ |
| ulala_backup.7z.009 | 3865636 | 1B8Zrb12UzZcJEI_NDxhgxa40KguZ9iTI |

Total expected bytes: 1933245476 (eight full volumes and one final volume).

**Evidence boundary:** These are provider-reported metadata, not downloaded file hashes or an archive integrity check. No actual meshes, rig data, animation clips or materials were extracted or examined in this step.

## Safe validation when all volumes are locally available
1. Download all volumes into a single temporary directory outside the Git repository.
2. Verify each file's byte count against the manifest.
3. Run `7z t ulala_backup.7z.001` to verify archive integrity.
4. Run `7z l ulala_backup.7z.001` to inspect the listing.
5. Extract only authorized, narrowly selected UnityFS bundles in an isolated workspace.
6. Run `python3 tools/analysis/audit_unity_metadata.py /path/to/selected/bundles --output /tmp/ulala_aggregate_audit.json`.
7. Do not commit source files, original asset payloads or identifiable asset metadata.
