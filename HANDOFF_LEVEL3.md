# Handoff Prompt — Build Level 3 for "The Last Move" (Godot 4.7.2)

> Paste everything below this line into the next agent (Claude Sonnet 4.6 / Antigravity CLI).
> It is fully self-contained: it assumes no memory, no prior task list, and no access to my scratch files.

---

## YOUR ROLE & GOAL

You are continuing work on a 24-hour hackathon game called **"The Last Move"**, a 2D pixel-art platformer built in **Godot 4.7.2** (team "Binary Brains"). The project root is the folder that contains `project.godot` (the `game` / `the-last-move` folder). Level 1 is finished and working; Level 2 is being built separately by a teammate and is **NOT in this copy of the project**.

**Your job: create a brand-new, independently playable Level 3.**

Deliverables:
- `res://levels/room_03.tscn` (the level scene)
- `res://scripts/room_03.gd` (the room controller — adapt from `room_01.gd`)
- Only create additional Level-3-specific resources if strictly necessary.

The previous agent (me) completed the **exploration + design-prep phase**: I read and understood the entire existing architecture, verified the tile data format, locked the art/palette decisions, and planned the layout. **No Level 3 files have been created yet.** Your job is to implement, verify, and report. All the hard-won facts you need are below — trust them, but verify against disk since files can change.

---

## HARD CONSTRAINTS (do not violate)

1. **DO NOT modify, overwrite, or break Level 1 (`res://levels/room_01.tscn`) or its scripts.** Level 2 is not in this copy — do not touch or assume it. Do NOT hard-code Level 3 to overwrite/replace Level 2. Use a clean transition so progression can later be wired Level 1 → 2 → 3. **Level 3 must remain independently playable for testing.**
2. **Reuse existing systems** (player, HUD, GameState, audio, spike, gem, moving platform, disappearing platform, mystery label, exit door). **Instance/reuse — do not duplicate or reimplement.** Do NOT create a second, incompatible score/HUD system.
3. **NO retro/CRT/VHS/scanline/pixel-distortion filters.** Pixel-art assets are fine, but keep pixels crisp and the presentation clean and modern.
4. **Do NOT introduce broken audio references.** The project had a real bug: `damage.wav` is actually an AIFF file (`FORM` header, not `RIFF`) and errors on import. `AudioManager` already remaps `damage` → `warning.wav`. **Only call existing AudioManager keys** — do not add raw audio file refs.
5. **Don't download external assets.** Reuse only what's in the project.
6. Write clean, Godot-4.7.2-compatible GDScript. The user is **still learning Godot** — explain major structural changes before making them, and give clear step-by-step editor instructions where relevant. Keep the project runnable at all times.
7. **Actually implement the scene** (don't just describe it). At the end, report: files created/changed, how to open `room_03.tscn`, how to test it directly, how the exit transitions, and any manual adjustments needed in the editor.

---

## DESIGN BRIEF (what Level 3 should be)

A **dark underground / abandoned-castle level**: blue/dark stone, dim atmosphere, lots of verticality, narrow platforms, spike traps, hidden dangers, gems, and a clear **LEFT → RIGHT** progression with a final exit door at the far right. Harder than Level 1 but **fair** — every jump must be possible with the existing movement (numbers below); the player should always be able to read the route.

Suggested beats (left → right): START → safe intro → small platforming → first spike trap → floating platforms → gem route → moving-platform section (over a spike pit) → harder spikes → mystery/special box → vertical climb → large dangerous gap → advanced platforming (incl. a disappearing/trap platform) → final challenge → EXIT DOOR → LEVEL COMPLETE.

Specific requirements:
- **Spikes must actually kill.** Visual must match collision (no invisible/misplaced hitboxes). Use small groups, pits, long strips, spikes under moving platforms, and spikes near careful jumps.
- **Moving platforms**: solid, carry the player smoothly and predictably, collision aligned to visuals. At least one section *requires* a moving platform to cross a dangerous gap.
- **Gems**: reuse the existing collectible, increase score, and guide the route (above platforms, between jumps, optional higher-risk routes, near danger).
- **≥1 mystery/special box** using the existing animated "Special Mystery?" label; player can interact/go for it; reuse, don't reimplement.
- **HUD** shows 3 hearts, `LEVEL: 3`, SCORE, and the existing timer — reuse the existing HUD, visually consistent with Level 1.
- **Death & game-over**: reuse existing systems (die → red flash + death sound → lose a heart (−100 score) → respawn at Level 3 spawn; three deaths → grayscale GAME OVER + press-R restart). Don't rewrite if it exists.
- **Background**: NOT a flat blue `ColorRect`. Build a dark atmosphere (deep-navy base + darkened silhouettes/decor via parallax) using existing assets, while keeping gameplay objects readable.
- **Exit door**: obvious, visually distinct, on a safe final platform, with working collision/interaction that triggers completion → "LEVEL COMPLETE" → transition.
- **Spawn**: a dedicated Level 3 spawn `Marker2D` named `PlayerSpawn` (NOT Level 1's position).
- **Camera** follows the player across the whole level; reuse the existing camera; don't reveal huge empty areas (set limits at runtime — see below).
- Use the dark-castle reference image as *composition inspiration, not an exact copy*; keep the Kenney Pixel Platformer art style.

---

## VERIFIED PROJECT ARCHITECTURE (trust these, they're confirmed from disk)

**Engine/config:** Godot 4.7.2, Mobile renderer, viewport 640×360, texture filter Nearest (crisp pixels). Input actions: `move_left` (A/←), `move_right` (D/→), `jump` (Space/W/↑), `ui_confirm` (Space/Enter). `main_scene = res://levels/room_01.tscn`.

**Autoload singletons (signal-based):**
- `GameState` (`res://scripts/autoload/game_state.gd`): `START_LIVES=3`. Vars: `lives`, `score`, `coins`, `world_label`, `time_left`. Methods: `lose_life()` (−100 score, fires `game_over` at 0), `add_coin(n=1)` (+100 each), `add_score(amt)`, `set_world_label(label)`, `start_room_timer(t)`, `stop_room_timer()`, `reset_run()`. Signals: `lives_changed`, `score_changed`, `coins_changed`, `time_changed`, `time_up`, `game_over`.
- `AudioManager` (`res://scripts/autoload/audio_manager.gd`): `play(name, volume_db=0.0, pitch=1.0)`. **Valid keys only:** `walk`, `damage`(→remapped to warning.wav), `death`, `warning`, `select`, `button`, `stage_clear`, `world_clear`. Unknown names are silently ignored.
- `GameManager` (`res://scripts/game_manager.gd`): has `ROOM_SCENES` array + `advance_room()` / `load_current_room()`. Room 3 is NOT registered here — don't force it in (keeps L2 untouched).

**Reuse contract — instance these scenes/scripts, don't duplicate.** (UIDs are what `room_01.tscn` references.)
- **Player** `res://scenes/player.tscn` (uid `cfpo0lh1je03y`): `CharacterBody2D`, `collision_layer=2`, `collision_mask=1`, script `player.gd`. **Has a child `Camera2D`** at `(0,-16)` with `limit_left=0`, `limit_bottom=360`, smoothing + drag enabled. Signals `died`, `reached_exit`; methods `take_damage()`, `die()`, `respawn(pos)`; property `spawn_position`. Body `CollisionShape2D` is a 12×32 rect at `(0,-16)` (origin at feet). Falls out (dies) if `position.y > 700`.
- **player.gd physics:** `SPEED=90`, `JUMP_VELOCITY=-240`, `GRAVITY=650`, `MAX_FALL=500`, `COYOTE_TIME=0.10`, `JUMP_BUFFER=0.10`, variable jump height (release cuts velocity ×0.45). Plays `select` (−6dB) on jump, `walk` (−18dB) footsteps.
- **spike** `res://scenes/hazards/spike.tscn` (uid `djq1p0xwabcde`): `Area2D` `collision_mask=2`, `body_entered → body.die()`. Sprite region = tile (9,3) = `Rect2(162,54,18,18)`; collision 14×9 at `(0,4.5)`. Script `res://scripts/spike.gd` (uid `bnkkbl853i3p`) is also reused standalone for a `DeathBox` Area2D.
- **gem** `res://scenes/interactables/gem.tscn` (uid `ci754x1no3glm`): `Area2D` `collision_mask=2`, floating tween, `body_entered → AudioManager.play("select",-6,1.5)` + `GameState.add_score(100)` + `queue_free()`. Sprite region = tile (7,3) = `Rect2(126,54,18,18)` (blue diamond).
- **moving_platform** `res://scenes/hazards/moving_platform.tscn` (uid `gbs6ogeu22ss`): `AnimatableBody2D` `collision_layer=1`, `@export offset_target` (default `(100,0)`), `@export duration` (2.0); loops via tween in physics process. Sprite region `Rect2(18,18,54,18)`; collision 54×18.
- **disappearing_platform** `res://scenes/hazards/disappearing_platform.tscn` (uid `bgbs6ogeu22ss`): `StaticBody2D` `collision_layer=1` + a top `Area2D` (`mask=2`) detector; crumbles on touch, disables collision ~2s, then restores. Great for trap/fake platforms. Sprite region `Rect2(18,18,54,18)`.
- **exit_door** `res://scenes/interactables/exit_door.tscn` (scene uid `zmq1p0xwabcde`; **referenced in room_01 as ext_resource uid `cgbs6ogeu22ss`** — use whichever resolves; check the door scene's own uid line): `Area2D` `mask=2`; on `body_entered` calls `body.reached_exit_door()` if present, else emits the player's `reached_exit`. **GOTCHA: its default Sprite2D `region_rect = Rect2(306,72,36,36)` is a TREE tile (17,4), not a door.** Override the instance's Sprite2D `region_rect` to **`Rect2(180,90,18,72)`** (wooden door, col 10, rows 5–8) in `room_03.tscn` ONLY — non-destructive, leaves Level 1 alone.
- **HUD** `res://scenes/ui/hud.tscn` (uid `hud_scene_1234`) + `hud.gd`: `CanvasLayer` built in code. Shows `"LEVEL: %s" % GameState.world_label`, `"SCORE: %04d"`, 3 hearts (♥), and on game-over a grayscale-shader fade + "GAME OVER"/"Press R to Retry" (R → `reset_run()` + `reload_current_scene()`). No gem/coin counter. So setting `world_label` to `"3"` renders `LEVEL: 3`.
- **mystery_label** `res://scripts/mystery_label.gd` (uid `dxlt7b7o0f0t2`): `extends Label`, floating bob tween. In room_01 the Label text is `"Special Mystery?\n↓"`.

**Room scene pattern (from `room_01.tscn`, `format=4`):**
```
Room03 (Node2D, script = room_03.gd)
├── Collision (Node2D)
│   └── many StaticBody2D (default collision_layer=1; each also sets collision_mask=2 — harmless for statics)
│         └── one CollisionShape2D each, RectangleShape2D, positioned at WORLD center coords
│            (These are MERGED collision strips/rectangles at world coords — NOT per-tile.)
├── ParallaxBackground
│   ├── ParallaxLayer (motion_scale ~0.1) → ColorRect "Sky"  (make it deep navy for L3, not blue)
│   ├── ParallaxLayer (motion_scale ~0.3) → TileMapLayer (24×24 background tileset, darkened)
│   └── ParallaxLayer (motion_scale ~0.6) → TileMapLayer (24×24 background tileset, darkened)
├── Terrain (TileMapLayer, 18px tileset, collision_enabled = false)   ← VISUAL ONLY
│      (optionally add modulate = Color(...) on this layer to tint tan tiles blue-gray stone)
├── <entity instances: Spike/Gem/MovingPlatform/DisappearingPlatform/ExitDoor>
├── PlayerSpawn (Marker2D)   ← Level-3 spawn position
├── DeathBox (Area2D + script spike.gd, mask=2)  ← optional, for pit kill zones
├── MysteryLabel (Label + mystery_label.gd, text "Special Mystery?\n↓")
└── HUD (instance of hud.tscn)
```
Collision is done with a **separate merged `StaticBody2D` per rectangle** (big rects, like room_01's hand-placed shapes) — the `Terrain` TileMapLayer has `collision_enabled = false` and is purely visual. Do NOT rely on tilemap collision.

**`room_03.gd`** — adapt directly from `room_01.gd` (which I've read; structure below). In `_ready()`: `_spawn_player()`, `GameState.start_room_timer(120.0)`, `GameState.set_world_label("3")`, connect `GameState.time_up`. Add **runtime camera-limit override** after spawning the player (because the shared player scene has `limit_bottom=360`, which would clip a taller level): set `_player.get_node("Camera2D").limit_right/limit_bottom/limit_top` to the actual Level 3 bounds. `_spawn_player()` reads `PlayerSpawn` position, `load("res://scenes/player.tscn")`, sets `spawn_position` + `position`, `add_child`, connects `died → _on_player_died` and `reached_exit → _on_reached_exit`. `_on_player_died()`: `stop_room_timer`, `GameState.lose_life()`, if `lives>0` wait 0.7s then `respawn_player()` + restart timer. `_on_reached_exit()`: stop timer, `AudioManager.play("stage_clear")`, `GameState.add_score(500)`, show a "LEVEL COMPLETE" message, wait ~1s, then transition. **For a clean, non-hardcoded transition** add `@export var next_scene_path: String = ""` and do: if `next_scene_path` is set and the file exists → `get_tree().change_scene_to_file(next_scene_path)`, else `get_tree().reload_current_scene()`. That keeps L3 independently playable now and chainable later without referencing L2.

`room_01.gd` for reference (adapt, don't copy world_label/timer verbatim):
```gdscript
extends Node2D
var _player : CharacterBody2D
var _spawn_world : Vector2
func _ready() -> void:
    _spawn_player()
    GameState.start_room_timer(120.0)
    GameState.set_world_label("1-1")   # <- use "3" for Level 3
    GameState.time_up.connect(_on_time_up)
func _spawn_player() -> void:
    var spawn_node = get_node_or_null("PlayerSpawn")
    _spawn_world = spawn_node.position if spawn_node else Vector2(45, 234)
    var scene : PackedScene = load("res://scenes/player.tscn")
    _player = scene.instantiate() as CharacterBody2D
    _player.spawn_position = _spawn_world
    _player.position = _spawn_world
    add_child(_player)
    _player.died.connect(_on_player_died)
    _player.reached_exit.connect(_on_reached_exit)
func respawn_player() -> void:
    if _player: _player.respawn(_spawn_world)
func _on_player_died() -> void:
    GameState.stop_room_timer(); GameState.lose_life()
    if GameState.lives > 0:
        await get_tree().create_timer(0.7).timeout
        respawn_player(); GameState.start_room_timer(120.0)
func _on_reached_exit() -> void:
    GameState.stop_room_timer(); AudioManager.play("stage_clear"); GameState.add_score(500)
    await get_tree().create_timer(1.0).timeout
    get_tree().reload_current_scene()   # <- replace with next_scene_path logic for L3
func _on_time_up() -> void:
    AudioManager.play("warning")
    if _player: _player.die()
```

---

## VERIFIED TECHNICAL FACTS

**`tile_map_data` binary format (round-trip verified byte-identical):** the `PackedByteArray("...")` on each `TileMapLayer` is base64 of: a little-endian `uint16` header (value `0`), followed by, per painted cell, the struct `<hhHHHH` = `(x, y, source_id, atlas_x, atlas_y, alternative)`. In Python:
```python
import struct, base64
def encode_tilemap(cells):  # cells = list of (x, y, source_id, atlas_x, atlas_y)
    data = struct.pack('<H', 0)
    for x, y, sid, ax, ay in cells:
        data += struct.pack('<hhHHHH', x, y, sid, ax, ay, 0)
    return base64.b64encode(data).decode()
```
Tiles are **18px** on the main tileset. `source_id` = 0 in these scenes. Coordinates `x,y` are tile (col,row). This is how room_01's `Terrain` layer is authored — reproduce it programmatically.

**Player jump/gap math (derived from SPEED/JUMP/GRAVITY, in px; 1 tile = 18px):**
- Max jump **rise ≈ 44px ≈ 2.4 tiles**. Design safe up-steps at **≤ 36px (2 tiles)**.
- Fair horizontal gap **≤ 54px (3 tiles)**; "easy" gap = **36px (2 tiles)**.
- When stepping **up 2 tiles**, keep the horizontal gap small (≈2 tiles) — combined up+across is the hardest case.
- Downward jumps can be wider (gravity helps): up to ~4 tiles across if landing ≥1 tile lower.
- Player dies if it falls to `position.y > 700`, so an open pit only kills if it drops that far; otherwise put a spike strip or a `DeathBox` Area2D at the pit bottom.

**Collision layers:** terrain/platforms = layer 1; player = layer 2 / mask 1; hazards/gems/door Area2Ds use mask 2 (so they detect the player). Merged static collision bodies default to layer 1 (they also set `collision_mask=2`, which is harmless for static bodies). Keep this convention.

**Tilesets (both already imported):**
- `res://assets/environment/kenney_pixel-platformer/Tilemap/tilemap_packed.png` (uid `75iwaeu2hlyn`): 360×162 = **20×9 grid @ 18px**. Confirmed tile coords (col,row): grass tops (0–2, 0); **tan/stone tops (0–2, 2) + fill (0–2, 3)** ← use these for platforms, tint cool blue-gray for castle stone; red brick (11–14, 0) ← ruined wall, darken; gray stone blocks (10–11, 4); gold "?"/coin boxes (8–10, 0) ← mystery box; wooden door (col 10, rows 5–8) = pixel `Rect2(180,90,18,72)`; orange banners (11–12, 5); **spike (9,3)**; **gem (7,3)**. Edge convention for a tops row is typically col0=left cap, col1=middle, col2=right cap (verify in preview).
- `res://assets/environment/kenney_pixel-platformer/Tilemap/tilemap-backgrounds_packed.png` (uid `c6gao0j2k8cck`): 192×72 = **8×3 grid @ 24px**, 4 palettes (blue/winter cols 0–3, orange/desert 4–5, green/forest 6–7); row 0 = sky, row 1 = hills + tree silhouettes, row 2 = solid fill. **Darken via `modulate`** on the parallax TileMapLayers for night/underground silhouettes.

**Locked art/palette decisions (from design-prep):**
- Play platforms = tan stone tiles (tops 0–2,2 + fill 0–2,3) with a cool blue-gray `modulate` on the Terrain layer (~`Color(0.52, 0.60, 0.85)` — tune in preview).
- Exit door = instance the existing scene, override its Sprite2D `region_rect` to `Rect2(180,90,18,72)`.
- Background = deep-navy `ColorRect` + darkened background-tileset hill/tree silhouettes across two parallax layers (motion_scale ~0.3 and ~0.6). NOT a flat blue sky.
- Mystery box = a solid gold "?" block (Sprite region tile (9,0) or (10,0) + a StaticBody collision so the player can bump/stand on it) with the "Special Mystery?" MysteryLabel floating above and a gem reward tucked above it.
- Planned level size ≈ **72–80 tiles wide × ~30–32 tall** (≈1300–1440 × 540–576 px), left→right with a vertical climb section in the back third. Camera limits set at runtime to these bounds.

---

## WHAT'S DONE vs. WHAT REMAINS

**DONE (design-prep phase):** Read and understood `room_01.tscn`, `room_01.gd`, `player.tscn`/`player.gd`, `exit_door.tscn`, `disappearing_platform.tscn`, and all autoloads. Verified the `tile_map_data` format round-trips byte-identical. Confirmed tile IDs and palette via rendered atlas previews. Locked the reuse contract, palette, and level-size/camera plan above. Confirmed `room_03.tscn`/`room_03.gd` do NOT yet exist on disk, and both tilesets + PIL are available.

**REMAINING — do these in order:**
1. **Design the Level 3 layout on an 18px grid.** Lay out platforms/gaps/spikes/gems/movers/mystery/climb/exit left→right following the beats above. Enforce the jump/gap rules (rise ≤44px, up-steps ≤36px with small gaps, flat gaps ≤54px).
2. **Write a single Python generator** (e.g. `build_room3.py`) that: defines the platform/entity model; computes **merged StaticBody2D collision rectangles** (greedy max-rectangle merge of solid cells, or simple per-run rectangles — few big rects like room_01); emits the `Terrain` `tile_map_data` PackedByteArray via the verified encoder; emits the two darkened background parallax `TileMapLayer`s; places all reused-scene instances (spikes, gems, moving/disappearing platforms, mystery box + label + reward gems, exit door with `region_rect` override, PlayerSpawn, optional DeathBox); and **renders a preview PNG** (PIL) so you can visually check composition and fairness *before* writing the scene. (Godot's editor can't run headless here, so the PNG preview + assertions are your verification.)
3. **Verify the layout** on the preview; add assertions that every intended jump satisfies the reachability rules; iterate until clean.
4. **Write `room_03.gd`** (adapt room_01.gd; `world_label` = `"3"`; runtime camera-limit override; exit → "LEVEL COMPLETE" + the `next_scene_path`-or-reload transition).
5. **Emit `room_03.tscn`** from the generator (correct ext_resources with the UIDs above, sub_resources for each RectangleShape2D + the two TileSets, and all nodes). Match `format=4` like room_01.
6. **Verify project integrity:** all ext_resource UIDs/paths resolve; `tile_map_data` decodes; collision rects line up with the visible platforms; spikes/gems/door use mask 2; no new/broken audio refs; **Level 1 files are byte-for-byte untouched**; camera bounds correct; no fall-through/walk-through.
7. **Final report** to the user: files created/changed; how to open `room_03.tscn` in Godot; how to test it directly (open the scene and press F6/"Run Current Scene", or temporarily set it as main scene); how the exit transitions (and how to later set `next_scene_path` for L1→2→3); and any manual editor adjustments needed.

**Verification workflow that works here:** build a Python (PIL) model of the level → emit both the `.tscn` and a rendered preview PNG → visually inspect the PNG and run reachability assertions → only then finalize. The Godot editor cannot be launched in this environment, so do NOT rely on opening the project to check; use the model + preview + careful reading of the emitted `.tscn` against room_01's proven structure.

**Style reminder:** clean, readable GDScript for Godot 4.7.2; explain any major structural change before doing it; give the user clear step-by-step Godot editor instructions in your final report (they're learning); keep the project runnable.
