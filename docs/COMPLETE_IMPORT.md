# Full source import – Update 168

The current GitHub repository does **not** yet contain the complete Godot game.
A source archive previously supplied for this project contains exactly **213 files**
and **371,692 bytes** of uncompressed content. Do not confuse a source manifest with
an actual source import.

## On Android with Termux

No new ZIP files need to be created. This procedure reads the existing archive
and commits the unpacked Godot source directly into the repository.

1. Install Termux and open it.
2. Run `pkg install git python -y` and `termux-setup-storage`.
3. Sign in to GitHub securely using your existing Git credential manager or a
   fine-grained personal access token restricted to this repository. Never paste
   a token into a ChatGPT conversation or project file.
4. Clone the project:

   `git clone https://github.com/xynewageyx/TitanLegend.git`

5. Enter the project directory:

   `cd TitanLegend`

6. Place or download the **existing** Update 168 archive to Android Downloads,
   then import its contents:

   `python tools/import_update_168.py ~/storage/downloads/Titan_Legends_Update_168_Gegner_KI_Tank_Fix.zip`

7. Review the changes and commit the **actual project files**:

   `git status --short`
   `git add -A`
   `git commit -m "Import all 213 original Update 168 source files"`
   `git push origin main`

8. Check the Godot CI workflow under GitHub Actions. An archive integrity check
   is not equivalent to a Godot runtime or Android build test.

If the file is not in Android Downloads, adjust the archive path to match its
actual location. The importer refuses unexpected file counts, lengths and unsafe
archive paths.

## Game rules requiring regression tests

- Four heroes per team; only one active tank.
- First tank to claim the role keeps it until a voluntary change or departure;
  later tank selections fail without automatic role displacement.
- Team bonus only for 1 tank / 2 DD / 1 healer.
- Only living active tank can taunt and intercept group damage.
- No tank self-regeneration and no resurrection.
- Verify dodge, critical hits, boss target selection, healing, and loot.
