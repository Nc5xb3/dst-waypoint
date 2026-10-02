# DST Modding Reference

A practical cheat-sheet for Don't Starve Together modding, focused on what this mod uses. Links to the original sources are at the bottom.

Klei never published a full official API reference. The real documentation is the **game's own Lua source**, plus community guides on the Klei forums.

## Where things live (Windows / Steam)

| What | Path |
|---|---|
| Local / dev mods | `C:\Program Files (x86)\Steam\steamapps\common\Don't Starve Together\mods\<folder>\` |
| Workshop mods (downloaded) | `C:\Program Files (x86)\Steam\steamapps\workshop\content\322330\<id>\` |
| Game Lua source | `…\Don't Starve Together\data\databundles\scripts.zip` – unzip somewhere outside the game folder and search it |
| Client log | `%USERPROFILE%\Documents\Klei\DoNotStarveTogether\client_log.txt` |
| Server logs | `…\DoNotStarveTogether\<cluster>\Master\server_log.txt`, `…\Caves\server_log.txt` |
| Persistent strings / client saves | `…\DoNotStarveTogether\<steam id>\client_save\` |

The folder name under `mods\` is the mod's internal id. The Workshop copy is `workshop-714735102`, and the test copy is `waypoint`, so both can be installed at once. Only enable one of them.

## Mod anatomy

```
<modfolder>/
  modinfo.lua         required – metadata, read by the Mods screen
  modmain.lua         required – entry point, run when the mod loads
  modworldgenmain.lua optional – runs during world generation
  modicon.tex/.xml    icon shown in the Mods screen
  scripts/            added to the require path (prefabs/, widgets/, screens/, components/ …)
  images/, anim/, sound/   assets referenced by Assets/PrefabFiles
```

### modinfo.lua fields

| Field | Notes |
|---|---|
| `name`, `description`, `author`, `version` | Display info. Bump `version` for every Workshop update. |
| `api_version` / `api_version_dst` | `6` for DS, `10` for DST (current). |
| `dst_compatible`, `dont_starve_compatible`, `reign_of_giants_compatible`, `shipwrecked_compatible`, `hamlet_compatible` | Which games list the mod. |
| `client_only_mod` | `true` means it runs only on the client (UI mods). It can be used on any server. |
| `all_clients_require_mod` | `true` means the server makes every client download it. Use `false` for client-only mods. |
| `server_only_mod` | Server-side only; clients don't need it. |
| `priority` | Higher loads first. This mod uses `-10000` so it loads last. |
| `icon_atlas`, `icon` | Mod icon. |
| `forumthread`, `server_filter_tags` | Server-browser and forum metadata. |
| `configuration_options` | List of `{ name, label, hover, options = {{description, data}}, default }`. Read in modmain with `GetModConfigData(name)`. |

`modinfo.lua` runs in a sandbox, so it has no game globals. Plain Lua such as loops and string functions is fine.

### The modmain environment

- Mod files run in their own environment, so game globals must be accessed through **`GLOBAL`** (`GLOBAL.TheSim`, `GLOBAL.ThePlayer`, `GLOBAL.require`). Some names are pre-imported, such as `Asset`, `Class` and `TUNING`, and the mod's `scripts/` files run in the global env.
- `modimport("file.lua")` runs another file in the **mod** environment (this mod uses it for localisation).
- `require "x"` loads `scripts/x.lua` (mod folder first, then the game).
- `Assets = { Asset("ATLAS", "images/x.xml"), Asset("IMAGE", "images/x.tex") }` and `PrefabFiles = { "myprefab" }` are picked up automatically.

### Common modutil API (modmain)

| Function | Use |
|---|---|
| `GetModConfigData(name)` | Read a config option. |
| `AddClassPostConstruct("widgets/controls", fn)` | Patch any class created from a file (widgets, screens, replicas). **This mod's main hook.** |
| `AddSimPostInit(fn)` | Run once the sim/world has loaded. |
| `AddPlayerPostInit(fn)` | Modify every player entity. |
| `AddPrefabPostInit(prefab, fn)` / `AddPrefabPostInitAny(fn)` | Modify prefabs. |
| `AddComponentPostInit(name, fn)` | Modify a component (not replicas – use ClassPostConstruct). |
| `AddStategraphPostInit`, `AddBrainPostInit` | Modify SGs / AI brains. |
| `AddAction`, `AddComponentAction` | Custom actions. |
| `AddRecipe` / `AddRecipe2`, `AddRecipeTab`, `AddCookerRecipe`, `AddIngredientValues` | Crafting & cooking. |
| `AddMinimapAtlas(atlas)` | Make minimap icons available (used for `flagmini.xml`). |
| `RegisterInventoryItemAtlas`, `RemapSoundEvent`, `AddReplicableComponent`, `AddModCharacter`, `AddPopup` | Misc. |

Rules of thumb:

- Server-side logic goes behind `if GLOBAL.TheWorld.ismastersim then … end`. Client-only mods like this one should never assume they are the master sim.
- To override something, wrap the original function and call it, rather than replacing it outright. For example, `local old = X.fn; X.fn = function(self, ...) … return old(self, ...) end`. This mod does this for `FrontEnd._ctor` and `MapWidget:OnUpdate/Offset/OnShow/OnZoomIn/OnZoomOut`.
- The widget system lives in the game's `scripts/widgets/*.lua` (`Widget`, `Image`, `ImageButton`, `Text`, `TextEdit`). Screens are in `scripts/screens/` and are pushed with `TheFrontEnd:PushScreen`.

## Testing and debugging

- **Console:** press `~` (backtick). Use Ctrl to toggle between local and remote execution. Useful commands:
  - `c_reset()` – reload the world/mods without restarting the game. Use it after redeploying.
  - `c_godmode()`, `c_supergodmode()`, `c_freecrafting()`, `c_spawn("prefab")`, `c_give("item", n)`, `c_teleport(x,0,z)` – common helpers.
  - `print(...)`, `dumptable(t)`, `print(debugstack())` – write to `client_log.txt`.
  - `ThePlayer.Transform:GetWorldPosition()` – handy for checking waypoint coordinates.
- **`GLOBAL.CHEATS_ENABLED = true`** plus `require "debugkeys"` turns on dev hotkeys and cheat behaviour. The test deploy script turns on `CHEATS_ENABLED` in the deployed copy only.
- Tail the log while playing, for example with PowerShell: `Get-Content "$env:USERPROFILE\Documents\Klei\DoNotStarveTogether\client_log.txt" -Wait -Tail 50`. A crash shows a stack trace on screen and in the log.
- The *Better Console* Workshop mod makes multi-line console input easier.
- For editing, VS Code with the *Lua* extension (sumneko) works well. Add the unzipped `scripts.zip` as a library to get go-to-definition into game code.

## Assets

- Textures are **`.tex`** (Klei format) paired with an **`.xml`** atlas listing named elements (`u1/u2/v1/v2`).
- Use **Don't Starve Mod Tools** (Steam > Library > Tools) or **Klei Studio / TEXTool** to convert PNG to TEX. The Mod Tools autocompiler also builds `exported/` PNGs into `images/` automatically.
- Atlas names in `Asset("ATLAS", …)` must match what widgets reference (`Image("images/nuiwp.xml", "flag.tex")`).

## Publishing to the Workshop

1. Install **Don't Starve Mod Tools** from Steam (Library > Tools).
2. Run the **ModUploader**, then pick the mod. It lists folders under the game's `mods\` directory.
   - Publish from a clean copy of `mod/` without the test patches. For example, copy `mod/` to `mods\waypoint-release`, or temporarily deploy without patches. Don't publish the `(TEST)` build.
3. Keep the same Workshop item (id `714735102`) when updating, and bump `version` in `modinfo.lua`.

## Sources and further reading

- Mod overview, folder locations and tools: <https://dontstarve.wiki.gg/wiki/Mod>
- modutil function documentation (forum): <https://forums.kleientertainment.com/forums/topic/127138-documentation-modutil-functions/>
- Ultroman's tutorial collection (newcomer intro, scripts.zip, logs, modinfo guide): <https://forums.kleientertainment.com/forums/topic/116302-ultromans-tutorial-collection-2020/>
- "A word about PostInit functions": <https://forums.kleientertainment.com/topic/51948-a-word-about-postinit-functions-addprefabpostinit-etc-and-more/>
- Setting up modmain/modinfo (forum Q&A): <https://forums.kleientertainment.com/forums/topic/102425-how-do-i-set-up-my-modmain-and-modinfo/>
- Uploading to the Workshop: <https://forums.kleientertainment.com/forums/topic/107918-how-to-upload/>
- Dev workflow tips (console, logs, paths): <https://github.com/mikesmullin/dst-base-mod>
- PersistentData (used by this mod): <http://forums.kleientertainment.com/files/file/1150-persistent-data/>
