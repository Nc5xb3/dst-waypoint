# Waypoint

Mark waypoints on DST

- [Klei forum page](https://forums.kleientertainment.com/files/file/1580-waypoint/)
- [Steam workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=714735102)

## Repo layout

| Path | What |
|---|---|
| `mod/` | The mod itself. Only this folder goes into the game or the Workshop. |
| `docs/ARCHITECTURE.md` | How this mod's code works. |
| `docs/MODDING.md` | General DST modding reference and links. |
| `deploy-test.ps1` / `deploy-test.bat` | Copies `mod/` into DST as a test build. |

## Test locally

Double-click `deploy-test.bat` (or run `.\deploy-test.ps1`). It mirrors `mod/` to
`C:\Program Files (x86)\Steam\steamapps\common\Don't Starve Together\mods\waypoint` and patches **only the copy**:

- `modinfo.lua` name becomes `Waypoint Mod (TEST)`
- `modmain.lua` has `GLOBAL.CHEATS_ENABLED = true` uncommented

Then enable **Waypoint Mod (TEST)** in DST and disable the Workshop version. After later edits, redeploy and run `c_reset()` in the console.

Use `-Destination "<path>"` if DST is installed in another Steam library.
