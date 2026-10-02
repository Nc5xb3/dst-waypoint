# Waypoint Mod – Code Overview

A **client-only** UI mod for Don't Starve Together (and, through a compatibility layer, single-player Don't Starve / RoG / SW / Hamlet). It lets a player drop named, coloured waypoints at their position, see them as on-screen indicators and map icons, and click one to auto-walk there.

- Workshop: <https://steamcommunity.com/sharedfiles/filedetails/?id=714735102>
- Klei forum: <https://forums.kleientertainment.com/files/file/1580-waypoint/>
- Current version: `1.0.8` (see `mod/modinfo.lua`)

## Repository layout

```
dst-waypoint/
├── mod/                     <- everything the game loads (this is what gets deployed/uploaded)
│   ├── modinfo.lua          metadata + configuration options shown in the Mods screen
│   ├── modmain.lua          entry point: assets, config, keybinds, HUD hooks
│   ├── modicon.tex/.xml     mod icon in the Mods screen
│   ├── stringlocalization_{en,jp,ru,zh,ko,pt}.lua   UI strings (global WAYPOINT table)
│   ├── images/              .tex textures + .xml atlases
│   └── scripts/             Lua modules, resolved by require "<path>"
├── docs/                    these docs
├── deploy-test.ps1 / .bat   copy mod/ into DST as a test build
└── README.md
```

Only `mod/` is copied to the game. `scripts/` inside it is added to the Lua search path by the game, so `require "mainwp"` loads `mod/scripts/mainwp.lua`.

## Load sequence

1. **`modinfo.lua`** is read by the Mods screen. Key flags: `client_only_mod = true`, `all_clients_require_mod = false`, `api_version_dst = 10`, `priority = -10000` (loads *after* Global Positions so our `MapWidget` override wins).
2. **`modmain.lua`** runs in the mod environment (`GLOBAL` holds the game's globals):
   - Declares `Assets` (atlases/images), `AddMinimapAtlas("images/flagmini.xml")`, and `PrefabFiles = { "flagplacer" }`.
   - Detects DS vs DST via `TheSim:GetGameID() == "DST"`.
   - Reads config with `GetModConfigData` (normalising booleans/tables because older saves stored `0/1`).
   - Loads keybinds from persistent string `waypoint_keybinds` (defaults: `X` toggles UI, indicators unbound; only A–Z accepted).
   - Picks the language: `auto` (default) maps the game's `LOC.GetLocaleCode()` to a mod file (`ja`→`jp`, `zht`/`zhr`→`zh`, unsupported → `en`); any other setting is used as-is. Then `modimport("stringlocalization_<LOC>.lua")` and publishes `STRINGS.WAYPOINT`.
   - If custom map icons are enabled, wraps `FrontEnd._ctor` to attach a global `TheFrontEnd.NMapIconTemplateManager`.
   - `AddClassPostConstruct("widgets/controls", AddMod)` – builds the UI once the HUD exists.
   - `AddClassPostConstruct("widgets/mapwidget", NMapWidget)` – draws waypoint icons on the big map.
3. **`AddMod(controls)`** (next frame via `DoTaskInTime(0, …)`):
   - Creates `MainWp` (the window) and `NIndicatorManager` under `controls.top_root`.
   - Hooks `controls.OnUpdate` to push player position to the window each frame while visible.
   - Registers key-down handlers for a–z **once per session** (`RegisterHotkeys`); they act on `activeControls`, the latest HUD's UI, so a rebuilt HUD (e.g. character swap) doesn't duplicate handlers. On rebuild the previous UI's marker entities and map-icon templates are removed (`MainWp:CleanupWorldObjects`). Shift+toggle key toggles indicators. Hotkeys are ignored when another screen or any waypoint dialog is open, or the player controller is disabled (this also covers text fields inside the HUD, like the crafting search).
   - Registers controller handlers once (`RegisterControllerControls`, see *Controller support* below).
   - Adds the HUD icon button (hidden on controllers or if `HIDE_HUD_ICON_WAYPOINT`).
   - Listens to `refreshhudsize` (DST) to rescale/reposition.

## Main modules (`mod/scripts/`)

| File | Role |
|---|---|
| `mainwp.lua` | **The core.** `MainWp` panel: paged waypoint list, add/edit/remove/reorder, toggle indicators, movement-prediction toggle, persistence, map icons, travel (`locomotor:GoToPoint`). |
| `waypoint.lua` | Plain model: `name`, `coord {x,y,z}`, `colour {r,g,b}`, `hidden`. |
| `persistentdata.lua` | Blueberrys' PersistentData v1.2 – JSON in a persistent string (`SavePersistentString`/`TheSim:GetPersistentString`). Non-release branches get the branch name appended to the save name. |
| `dialogedit.lua` | Edit modal: name, X/Z, colour palette, randomise, move up/down, toggle visibility, delete. |
| `dialogconfig.lua` | Config modal: opens keybind dialog; shows debug info (UWID, waypoint count). |
| `dialogkeybinds.lua` + `screens/keybindscreen.lua` | Capture a key (A–Z) or Backspace to clear. |
| `dialogmp.lua` | Warning shown when travel is attempted with movement prediction off. |
| `styler.lua` + `util/nstyler.lua` | "CSS-like" skinning of `NPanel`s by class (`Frame`, `ListItem`, …); skin 0 = plain, 1 = DST-like. |
| `prefabs/flagplacer.lua` | Invisible, non-persistent entity placed at a waypoint; targets for indicators and (fallback) minimap icon. |
| `widgets/npanel.lua` | `Widget` with a size and class list – base of all mod UI. |
| `widgets/nindicator*.lua` | Off-screen/edge indicators (based on DS `targetindicator.lua`), clickable to travel. |
| `widgets/nmapwidget.lua` | Post-construct for `MapWidget`: positions custom icons each frame using the game's own projection (`minimap:WorldPosToMapPos`), so rotation, zoom and panning stay in sync; suppresses icon clicks after a drag. Credit: rezecib's Global Positions. |
| `widgets/nmapicon*.lua` | Map icon template + manager (templates live on `TheFrontEnd` so they survive map reopen). |
| `widgets/ninput.lua`, `ncolourpalette.lua`, `nslider.lua` | Small custom widgets. |
| `widgets/dst*.lua` | DST-style widget back-ports used when running in single-player DS. |
| `util/compatibility.lua` | Singleton: `ThePlayer()`, `TheWorld()`, and widget class pickers for DS vs DST. |
| `util/nbox.lua` | Layout helper: grid positions with top-left origin. |
| `util/adjectivesutility.lua` | Random adjective for new waypoint names ("<Adjective> <Tile>"). |
| `util/utf8*.lua` | UTF-8 helpers for text input. |

## Data & persistence

- All waypoints live in the persistent string **`waypoint`** (client side, not the world save), as a JSON object keyed by **UWID**:
  - `uwid = "waypoint_" .. (TheWorld.meta.session_identifier or seed) [.. "_C" in caves]`
  - Older versions keyed by `seed`; `LoadData()` migrates `waypoint_<seed>` entries into the session-identifier key once.
- Keybinds live in **`waypoint_keybinds`**.
- Persistent strings are stored under `Documents/Klei/DoNotStarveTogether/<id>/client_save/` (Steam cloud may sync them).

## Behaviour notes / gotchas

- **Travel** requires movement prediction ON (DST: `ThePlayer.components.locomotor` exists only then). Otherwise the MP toggle button is revealed and `DialogMp` explains why.
- `UpdateList()` also calls `SaveData()` – every page change writes to disk.
- `pageSize = floor(height / 45) - 2` rows.
- Indicators (`markerMode`) spawn a `flagplacer` per visible waypoint; toggling off removes them all.
- `DISABLE_CUSTOM_MAP_ICONS` falls back to the vanilla minimap icon `flagmini.tex` on the `flagplacer` (only exists while indicators are on).
- Localisations must define every key used in `STRINGS.WAYPOINT` – a missing key shows as blank text (or errors where it's concatenated). Keep all `stringlocalization_*.lua` files in sync with `en`. New language = new file + entry in `SUPPORTED_LOCALIZATIONS`/`GAME_LOCALE_TO_MOD` (modmain) + option in modinfo.
- The commented "FOR MOD DEVELOPMENT" block in `modmain.lua` (`GLOBAL.CHEATS_ENABLED`, `require "debugkeys"`) is enabled automatically in the test deploy – never ship it uncommented.

## Controller support

Controller actions only work **while the scoreboard is held open** (DST: hold the player-status button, Back/View; single-player DS: on the pause screen):

| Button | Action |
|---|---|
| LT (`CONTROL_OPEN_CRAFTING`) | Toggle waypoint indicators |
| RT (`CONTROL_OPEN_INVENTORY`) | Add a waypoint at your position, or remove the one you're standing on (within 0.7 tiles) |

The scoreboard's help bar lists these (post-construct on `screens/playerstatusscreen`).

Why this doesn't conflict with game controls:
- `TheInput` control handlers only receive controls the active screen did **not** consume (`Input:OnControl` checks `TheFrontEnd:OnControl` first). Anything the scoreboard uses (B, X, Y, LB/RB list paging, d-pad, A) never reaches the mod.
- While the scoreboard is open the HUD isn't the active screen, so LT/RT don't open crafting/inventory and the player controller is disabled.
- During normal play the HUD consumes LT/RT, so the mod's handler doesn't fire, and it also checks the active screen is the scoreboard.
- Ignored when no controller is attached (keyboard users use keybinds) or a waypoint dialog is open.

Not covered yet: navigating the waypoint window or travelling to a waypoint with a controller.

## Config options (`modinfo.lua`)

| Key | Default | Meaning |
|---|---|---|
| `LOCALIZATION_MOD_WAYPOINT` | `auto` | `auto` (match game language) / `en` / `ru` / `jp` / `zh` / `ko` / `pt` |
| `SKIN_MOD_WAYPOINT` | `1` | 0 Plain, 1 DST-like |
| `SHOW_WAYPOINT_INDICATORS` | `true` | indicators on at start |
| `ENABLE_CONTROLLER_SUPPORT` | `true` | controller actions on the scoreboard (see below) |
| `WIDTH_MOD_WAYPOINT` / `HEIGHT_MOD_WAYPOINT` | 360 / 480 | window size (300–600) |
| `COLOUR_PALETTE_VARIETY` | 8 | palette step (lower = more colours) |
| `HIDE_HUD_ICON_WAYPOINT` | false | hide HUD button |
| `DISABLE_CUSTOM_MAP_ICONS_WAYPOINT` | false | use vanilla minimap icon instead |
| `ALWAYS_SHOW_MP_WAYPOINT` | false | always show MP toggle (DST) |
| `SHOW_COORDINATES` | false | show X/Z in list and footer |
| `DISABLE_AUTO_TRAVEL` | false | clicking flags doesn't walk |

## Dev workflow

1. Edit files in `mod/`.
2. Run `deploy-test.bat` (or `deploy-test.ps1`) – mirrors `mod/` to `…\Don't Starve Together\mods\waypoint`, renames to **Waypoint Mod (TEST)** and enables cheats in the copy.
3. In DST: disable the Workshop "Waypoint Mod", enable "Waypoint Mod (TEST)", host a world.
4. After further edits: redeploy, then `c_reset()` in the console (~ key) to reload.
5. Check `Documents\Klei\DoNotStarveTogether\client_log.txt` for `[waypoint]` prints and stack traces.
6. To publish: upload the **`mod/`** folder (unpatched) with the *Don't Starve Mod Tools* uploader, bumping `version` in `modinfo.lua`.

See [MODDING.md](MODDING.md) for general DST modding reference.
