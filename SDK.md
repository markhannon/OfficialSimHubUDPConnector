# Assetto Corsa CSP Lua SDK Guide

Use this guide when creating, reviewing, or debugging Lua scripts for Assetto Corsa with Custom Shaders Patch (CSP), especially this repository's SimHub UDP Connector app.

## Goals

- Use the CSP Lua API and callback model correctly.
- Prefer the API definitions shipped with the installed CSP version over guessed or outdated signatures.
- Follow this repository's extension-loading and data-export conventions.
- Guard version-dependent features and handle unavailable game state.

## Source of truth

1. **Installed CSP SDK definitions:** `<Assetto Corsa installation>\extension\internal\lua-sdk`. CSP's SDK README says these EmmyLua definitions document the API and can be configured for editor completion. Use the definitions that match the user's installed CSP build.
2. **Official SDK repository:** [ac-custom-shaders-patch/acc-lua-sdk](https://github.com/ac-custom-shaders-patch/acc-lua-sdk). Its README describes script types, callbacks, SDK setup, and example sources.
3. **Official examples and libraries:**
   - [acc-lua-examples](https://github.com/ac-custom-shaders-patch/acc-lua-examples)
   - [acc-lua-internal](https://github.com/ac-custom-shaders-patch/acc-lua-internal)
   - [acc-lua-sdk wiki](https://github.com/ac-custom-shaders-patch/acc-lua-sdk/wiki)
4. **Repository examples:** inspect existing extensions under `Assetto Corsa/apps/lua/SimHubUDPConnector/extensions/` and the app entry point before changing code.

The CSP Lua API is versioned with CSP. Do not assume a function, field, or callback is present merely because it appears in an online example or in a newer SDK checkout.

## Runtime model and API conventions

- CSP loads common Lua libraries and then libraries for the script type. Script types expose different `script.*` callbacks; use the callback documented for the script type rather than assuming every script has the same lifecycle.
- CSP looks for `script.*` callbacks before legacy global callback names. Callback references are captured when the script is initialized, so defining or replacing them later may not take effect.
- The CSP SDK uses LuaJIT with Lua 5.2 compatibility, not stock standalone Lua. Use the installed SDK definitions for types and API signatures.
- Car indices are **zero-based**. `ac.getCar(0)` refers to the player's car; other indices address other cars. The SDK's `ac.getCar` declaration permits a missing result, so guard before dereferencing when the selected index or game state is not guaranteed.
- Read API details such as field types, units, mutability, callback timing, and version availability from the matching SDK definitions. Do not infer them from a field name.

## Repository-specific integration

The connector is a CSP app that collects data and sends it to SimHub. Its main app callbacks are in `Assetto Corsa/apps/lua/SimHubUDPConnector/SimHubUDPConnector.lua`; custom data extensions are Lua modules in its `extensions` folder.

For a normal data extension:

1. Create a module in `Assetto Corsa/apps/lua/SimHubUDPConnector/extensions/`.
2. Follow the existing module pattern: define a table, implement `ExtensionName:update(dt, customData)`, and return the table.
3. Add properties to `customData` using stable, descriptive keys. The connector serializes that table for the outgoing SimHub payload.
4. Keep each update bounded. Cache stable references where the existing code does so, and throttle expensive work (sorting, file reads, or repeated configuration queries) when frame-level updates are unnecessary.
5. Handle unavailable values explicitly. CSP/game state may be unavailable in menus, replay, or transitional states; do not assume every API result or field is populated.
6. If the extension should be discoverable or enabled by default, update the relevant extension configuration in the app and preserve the existing activation behavior.

Existing starter: `extensions/SampleUserExtension.lua`. Existing API usage includes `ac.getCar`, `ac.getSim`, `ac.getPatchVersion`, `ac.getPatchVersionCode`, and `ac.iterateCars`; confirm each API's signature in the installed SDK before introducing new usage.

Example extension shape:

```lua
local UserExtension = {}

function UserExtension:update(dt, customData)
  local carState = ac.getCar(0)
  local sim = ac.getSim()

  if not carState then
    return
  end

  customData.AmbientTemperature = sim.ambientTemperature
  customData.Autoclutch = carState.autoClutch
end

return UserExtension
```

Treat the example fields and cached state behavior as illustrative, not a guarantee that those fields exist in every CSP version or in every runtime state. Check the SDK and follow nearby repository code when implementing a real extension.

## Compatibility and reliability checklist

- Check the SDK definition and CSP minimum version for every API added.
- For version-gated behavior, compare using the repository's existing version-checking approach (for example, `ac.getPatchVersionCode()`), and provide a clear fallback or error property when the feature is unavailable.
- Do not silently substitute unrelated values when game data is missing. Preserve `nil` where appropriate or expose an explicit status/error using the project's established conventions.
- Be careful with replay and session transitions; existing extension code documents cases where values can be `nil` or functionality is unsupported.
- Keep work out of the per-frame path when possible. Use `dt` to accumulate elapsed time for less frequent updates and retain the last known result if appropriate.
- Avoid relying on undocumented globals, undocumented enum numbers, or copied snippets whose CSP version is unknown.
- Preserve connector behavior: extensions should add/update `customData`, not bypass the app's payload and UDP path.

## Development workflow

1. Read the relevant app code and a nearby extension before editing.
2. Identify the installed CSP version and inspect its `extension/internal/lua-sdk` definitions for each API involved.
3. Implement the smallest extension or app change consistent with nearby code.
4. Review every dereference of CSP/game state for valid-state and `nil` handling.
5. Verify syntax with the project's available Lua tooling. If the CSP runtime is available, load the app in Assetto Corsa and inspect the CSP Lua Debug app for errors and callback timing.
6. State which CSP version was used for runtime verification; if it was not run in-game, say so rather than implying runtime compatibility was confirmed.

## Reference links

- [CSP Lua SDK repository and setup notes](https://github.com/ac-custom-shaders-patch/acc-lua-sdk)
- [CSP Lua SDK source definitions](https://github.com/ac-custom-shaders-patch/acc-lua-sdk/tree/main/common)
- [CSP Lua example scripts](https://github.com/ac-custom-shaders-patch/acc-lua-examples)
- [CSP internal Lua libraries and included apps](https://github.com/ac-custom-shaders-patch/acc-lua-internal)
- [CSP default WeatherFX implementation](https://github.com/ac-custom-shaders-patch/acc-weatherfx-base)
