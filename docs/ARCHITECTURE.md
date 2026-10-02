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
| `dialogconfig.lua` | Configurations modal: keybinds + in-game settings (live), debug info popup. |
| `dialogkeybinds.lua` + `screens/keybindscreen.lua` | Capture a key (A–Z) or Backspace to clear. |
| `screens/waypointcontrollerscreen.lua` | Controller navigation of the window and its dialogs (cursor, highlight, help bar), see *Controller support*. |
| `dialogmp.lua` | Warning shown when travel is attempted with movement prediction off. |
| `styler.lua` + `util/nstyler.lua` | "CSS-like" skinning of `NPanel`s by class (`Frame`, `ListItem`, …); skin 0 = plain, 1 = DST-like. |
| `prefabs/flagplacer.lua` | Invisible, non-persistent entity placed at a waypoint; targets for indicators and (fallback) minimap icon. |
| `widgets/npanel.lua` | `Widget` with a size and class list – base of all mod UI. |
| `widgets/nindicator*.lua` | Off-screen indicators (based on DS `targetindicator.lua`), clickable to travel. Placed where a ray from the screen centre, in the target's direction, meets the indicator area. |
| `indicatorarea.lua` | Shared indicator-area settings + geometry (shape, size, screen-edge buffers, ray/outline maths). |
| `dialogindicatorarea.lua` | Compact Indicator area panel (bottom-right, above the HUD buttons; position scaled with the UI): shape (Rectangle/Oval/Circle), size (30–100 %), names (Always/On hover), live dotted outline on the indicator layer. The outline is where indicator flag centres sit. While open, MainWp hides its other windows and turns indicators on (restored on close). |
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

**How to open it (DST):** the controller's Back/View button opens the game's **social menu / command wheel** (`CONTROL_OPEN_COMMAND_WHEEL`). The mod adds two items to it:

| Wheel item | Action |
|---|---|
| Waypoints (`images/icon.xml`) | Open the waypoint window for controller use (`MainWp:OpenWithController`); without a controller it just toggles the window |
| Waypoint indicators (`nuiwp.xml` marker) | Toggle waypoint indicators |

Hooked with a post-construct on `widgets/controls`: `commandwheel.SetItems` is wrapped to append the items to the root dataset (`dataset_name == nil`), then `Controls:BuildCommandWheel()` is called once more (the constructor already built it). The HUD rebuilds the wheel later (mount/invite changes) through the same `SetItems`, so the items stay. The wheel runs `execute` and then closes itself (`OnExecute` → `PlayerHud:CloseCommandWheel`).

> Gotcha (why the first version "did nothing"): DST no longer has a hold-to-show scoreboard on controllers. `CONTROL_SHOW_PLAYER_STATUS` has no controller binding (`screens/redux/optionsscreen.lua`), and Back/View opens the command wheel, which is a HUD widget, so the HUD stays the active screen and consumes LT/RT (crafting / inventory). Check the game's `scripts.zip` before relying on a controller button.

**Fallback, the scoreboard** (DST: *Player List* in the command wheel; single-player DS: the pause screen): RT opens the window, LT toggles indicators. `TheInput` control handlers only receive controls the active screen did **not** consume, and the scoreboard doesn't use LT/RT; the help bar lists them (post-construct on `screens/playerstatusscreen`). Ignored when no controller is attached or a waypoint dialog is open.

### Navigating the window (`screens/waypointcontrollerscreen.lua`)

The window is a HUD widget, not a Screen, so the game's focus system can't reach it. `OpenWithController` pushes an invisible `WaypointControllerScreen` on top of the HUD. It consumes every control (the player can't move, LT/RT don't open crafting) and keeps its own cursor on the **topmost waypoint panel** (`MainWp:GetControllerPanel`: indicator area > keybinds > configurations > MP warning > edit dialog > window):

- **Highlight:** a gold outline + translucent fill around the selected item and a tooltip above it (the node's `hint`, else the widget's tooltip). The selected widget also gets `OnGainFocus`/`OnLoseFocus`, so buttons grow and play the hover sound like on mouse-over.
- **Help bar:** `GetHelpText` lists the actions of the selected item.
- Panels describe their items with `GetControllerRows(screen)` (rows of nodes: `widget`, `onaccept` (default: the button's `onclick`), `onleft`/`onright`, `onx`/`ony`, labels, `hint`). Hidden widgets are skipped. Optional `OnControllerCancel`, `OnControllerPage`, `GetControllerDefaultFocus`. The cursor stays on the same item by `id` across refreshes (the layout is rebuilt every frame).
- Directions: in DST the front end turns the d-pad / left stick into `OnFocusMove(MOVE_*)` calls, repeating while held (`FrontEnd:Update`), so `CONTROL_FOCUS_*` controls are only used as a fallback in DS. LB/RB are `CONTROL_SCROLLBACK/FWD` (also repeated by the front end). Buttons act on **release** and only if the press was seen (so the RT release that opened the screen, or a popup's last press, does nothing).
- `onaccept` may return a **capture** (`ondir`, `onshoulder`, `help`): the d-pad then goes to it until A/B. Used by the colour palette (`NColourPalette:StepHSV`).
- The screen closes itself if the window is hidden some other way or the HUD is rebuilt; closing also closes any waypoint dialogs and hides the window (`MainWp:OnControllerScreenClosed`).

| Panel | Items |
|---|---|
| Window | Configurations · Indicators · Add (cursor jumps to the new waypoint) / each waypoint: name (A edit, X show/hide, Y delete) and flag (A travel; closes the window first so the player controller is active again) / MP toggle · Prev · Next / Close. LB/RB change page, B closes. |
| Edit | Up · Down · Visibility · Delete / Name / X · Z / Random colour · Palette (A: d-pad = hue/shade, LB/RB = brightness) / Save · Cancel. B cancels. |
| Configurations, Keybinds, MP warning | Each button in order; B closes. Keybind capture still needs a keyboard (B cancels it). |
| Indicator area | Shape, Size, Names (left/right change the value) / Close. |

Text fields (name, X/Z) open the usual `NInputScreen`, which needs a keyboard (DST only opens a virtual keyboard on Steam Deck; Steam's overlay keyboard works); B cancels it. Controller-only shortcuts: X on the name = new random name (`MainWp:GenerateName`), Y on X/Z = use my position.

Highlight sizes use each widget's **own** scale (`inst.UITransform:GetScale()`); `Widget:GetScale()` in DST multiplies in every parent, including the HUD scale.

## Config options (`modinfo.lua`)

Only things that need a restart or are rarely changed stay here:

| Key | Default | Meaning |
|---|---|---|
| `LOCALIZATION_MOD_WAYPOINT` | `auto` | `auto` (match game language) / `en` / `ru` / `jp` / `zh` / `ko` / `pt` |
| `SKIN_MOD_WAYPOINT` | `1` | Window style: 0 Plain, 1 DST-like |
| `WIDTH_MOD_WAYPOINT` / `HEIGHT_MOD_WAYPOINT` | 360 / 480 | window size (300–600) |
| `SHOW_WAYPOINT_INDICATORS` | `true` | indicators on when joining a world |
| `COLOUR_PALETTE_VARIETY` | 8 | palette step (lower = more colours) |
| `ALWAYS_SHOW_MP_WAYPOINT` | false | "Movement prediction button": When needed / Always |
| `ENABLE_CONTROLLER_SUPPORT` | `true` | controller: social-menu items (and scoreboard LT/RT) to open the window / toggle indicators, and window navigation (see above) |

## In-game settings (Configurations dialog)

Saved per client in the persistent string `waypoint_settings` (`WAYPOINT_SETTINGS` in modmain) and applied immediately via `controls.waypoint.setSetting(key, value)` → `ApplySetting`.

| Key | Default | Effect |
|---|---|---|
| `show_hud_button` | true | HUD button (never shown with a controller attached) |
| `map_icons` | `all` | `all` / `visible` (hide waypoints marked hidden) / `off`; read each time the map opens (`MainWp:ShouldShowMapIcon`) |
| `show_coordinates` | false | X/Z in the list and footer (`MainWp:SetShowCoordinates`) |
| `click_to_travel` | true | click a flag (list, indicator, map icon) to walk there (`MainWp:SetClickToTravel`) |
| `indicator_shape` | `rectangle` | `rectangle` / `ellipse` (Oval) / `circle`; edited in the Indicator area dialog |
| `indicator_area_size` | 50 | percent of the largest area that fits the screen (30–100, steps of 10). 50 % rectangle ≈ the old placement. (Renamed from `indicator_size` so early test saves reset to 50.) |
| `indicator_names` | `always` | `always` / `hover`: indicator name label only while hovering the flag (`IndicatorArea.namesOnHover`, read by NIndicator each frame) |

These replaced the modinfo options `HIDE_HUD_ICON_WAYPOINT`, `DISABLE_CUSTOM_MAP_ICONS_WAYPOINT`, `SHOW_COORDINATES` and `DISABLE_AUTO_TRAVEL`. On first run (no saved settings) the old values are carried over if the game still reports them. The old "disable custom map icons" fallback to vanilla minimap icons is gone; `map_icons = off` hides them instead.

Debug info (UWID, waypoint count) is behind the small "Debug info" button and shown in a popup.

## Dev workflow

1. Edit files in `mod/`.
2. Run `deploy-test.bat` (or `deploy-test.ps1`) – mirrors `mod/` to `…\Don't Starve Together\mods\waypoint`, renames to **Waypoint Mod (TEST)** and enables cheats in the copy.
3. In DST: disable the Workshop "Waypoint Mod", enable "Waypoint Mod (TEST)", host a world.
4. After further edits: redeploy, then `c_reset()` in the console (~ key) to reload.
5. Check `Documents\Klei\DoNotStarveTogether\client_log.txt` for `[waypoint]` prints and stack traces.
6. To publish: upload the **`mod/`** folder (unpatched) with the *Don't Starve Mod Tools* uploader, bumping `version` in `modinfo.lua`.

See [MODDING.md](MODDING.md) for general DST modding reference.
