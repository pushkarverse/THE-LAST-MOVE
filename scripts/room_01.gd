extends Node2D
## Room 01 - "The Introduction"
## Visual tiles are drawn via TileMapLayer (display only, no physics).
## Collision is handled by StaticBody2D nodes built at runtime - guaranteed to work.
## Grid: 26 tiles wide x 15 tiles tall @ 18 px each = 468 x 270 px

# ──────────────────────────────────────────
#  Room constants
# ──────────────────────────────────────────
const TILE_SIZE  : int = 18
const ROOM_W     : int = 26
const ROOM_H     : int = 15

## Centre the 468x270 room inside the 640x360 viewport
const ROOM_OFFSET : Vector2 = Vector2(
    (640 - 26 * 18) / 2,   # = 86
    (360 - 15 * 18) / 2    # = 45
)

## Spawn tile (col, row) - player feet land on top of floor row 12
const SPAWN_TILE : Vector2i = Vector2i(2, 12)

# ──────────────────────────────────────────
#  Tile atlas coords in tilemap_packed.png
#  Sheet: 20 cols x 9 rows, 18 px each, packed (no gaps).
# ──────────────────────────────────────────
const T_FILL  : Vector2i = Vector2i(2, 6)   # solid interior block
const T_TOP   : Vector2i = Vector2i(2, 5)   # ground surface tile
const T_PLAT  : Vector2i = Vector2i(0, 3)   # thin platform tile
const T_WALL  : Vector2i = Vector2i(1, 6)   # wall tile

# ──────────────────────────────────────────
#  Node refs
# ──────────────────────────────────────────
var _tile_layer  : TileMapLayer
var _collision   : Node2D        # parent for all StaticBody2D nodes
var _player      : CharacterBody2D
var _spawn_world : Vector2
var _source_id   : int = 0


func _ready() -> void:
    _build_background()
    _build_visual_tiles()
    _build_collision()
    _spawn_player()
    GameState.start_room_timer(60.0)
    GameState.set_world_label("1-1")
    GameState.time_up.connect(_on_time_up)


# ──────────────────────────────────────────
#  Background
# ──────────────────────────────────────────
func _build_background() -> void:
    var parallax := ParallaxBackground.new()
    add_child(parallax)

    var bg_layer := ParallaxLayer.new()
    bg_layer.motion_scale = Vector2(0.2, 0.2)
    bg_layer.motion_mirroring = Vector2(640, 360)
    parallax.add_child(bg_layer)

    var bg := ColorRect.new()
    bg.name    = "Background"
    bg.color   = Color(0.12, 0.13, 0.21)
    bg.size    = Vector2(640, 360)
    bg_layer.add_child(bg)

    # Background tiles (mountains/clouds)
    var ts := TileSet.new()
    ts.tile_size = Vector2i(24, 24)
    var src := TileSetAtlasSource.new()
    src.texture = load("res://assets/environment/kenney_pixel-platformer/Tilemap/tilemap-backgrounds_packed.png")
    src.texture_region_size = Vector2i(24, 24)
    for row in range(3):
        for col in range(8):
            src.create_tile(Vector2i(col, row))
    ts.add_source(src)

    var bg_tiles := TileMapLayer.new()
    bg_tiles.tile_set = ts
    bg_tiles.modulate = Color(0.4, 0.4, 0.5) # Darken and push back for night depth
    bg_layer.add_child(bg_tiles)

    # Paint repeating background elements (mountains at bottom, clouds in sky)
    for x in range(28):
        bg_tiles.set_cell(Vector2i(x, 14), 0, Vector2i(x % 4, 1))
        if x % 4 == 0:
            bg_tiles.set_cell(Vector2i(x, (x % 3) + 2), 0, Vector2i(x % 3, 0))


# ──────────────────────────────────────────
#  Visual-only TileMapLayer (NO physics)
# ──────────────────────────────────────────
func _build_visual_tiles() -> void:
    var ts := TileSet.new()
    ts.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)

    var src := TileSetAtlasSource.new()
    src.texture = load(
        "res://assets/environment/kenney_pixel-platformer/Tilemap/tilemap_packed.png")
    src.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)

    # Register all 180 tiles - VISUAL ONLY, no collision polygons
    for row in range(9):
        for col in range(20):
            src.create_tile(Vector2i(col, row))

    _source_id = ts.add_source(src)

    _tile_layer          = TileMapLayer.new()
    _tile_layer.name     = "Terrain"
    _tile_layer.tile_set = ts
    _tile_layer.position = ROOM_OFFSET
    # Disable the TileMapLayer's own collision entirely - we use StaticBody2D instead
    _tile_layer.collision_enabled = false
    add_child(_tile_layer)

    _paint_tiles()


func _paint_tiles() -> void:
    # Ceiling row 0
    for x in range(ROOM_W):
        _t(x, 0, T_FILL)
    # Walls
    for y in range(1, ROOM_H):
        _t(0, y, T_WALL)
        _t(ROOM_W - 1, y, T_WALL)
    # Floor surface row 12 (pits at cols 5-7 and 18-19)
    for x in range(1, ROOM_W - 1):
        if not (x >= 5 and x <= 7) and not (x >= 18 and x <= 19):
            _t(x, 12, T_TOP)
    # Floor fill rows 13-14
    for y in range(13, ROOM_H):
        for x in range(1, ROOM_W - 1):
            _t(x, y, T_FILL)
    # Nice Platforms A (cols 9-11, row 5)
    _t(9, 5, Vector2i(1, 1))
    _t(10, 5, Vector2i(2, 1))
    _t(11, 5, Vector2i(3, 1))

    # Nice Platforms B (cols 14-16, row 8)
    _t(14, 8, Vector2i(1, 1))
    _t(15, 8, Vector2i(2, 1))
    _t(16, 8, Vector2i(3, 1))

    # Decorations (Bushes and props on the floor)
    _t(3, 11, Vector2i(8, 3))   # bush
    _t(4, 11, Vector2i(9, 3))   # bush
    _t(10, 11, Vector2i(9, 1))  # window/sign
    _t(12, 11, Vector2i(8, 3))  # bush


func _t(col: int, row: int, atlas: Vector2i) -> void:
    _tile_layer.set_cell(Vector2i(col, row), _source_id, atlas)


# ──────────────────────────────────────────
#  Solid collision via StaticBody2D nodes
#  Uses RectangleShape2D blocks - simple and reliable.
#  collision_layer = 1 (terrain), collision_mask = 2 (player)
# ──────────────────────────────────────────
func _build_collision() -> void:
    _collision = Node2D.new()
    _collision.name = "Collision"
    add_child(_collision)

    # Ceiling (row 0, full width)
    _solid_rect(0, 0, ROOM_W, 1)

    # Left wall (col 0, rows 1-14)
    _solid_rect(0, 1, 1, ROOM_H - 1)

    # Right wall (col 25, rows 1-14)
    _solid_rect(ROOM_W - 1, 1, 1, ROOM_H - 1)

    # Floor section 1: cols 1-4, row 12-14
    _solid_rect(1, 12, 4, 3)

    # Floor section 2: cols 8-17, row 12-14
    _solid_rect(8, 12, 10, 3)

    # Floor section 3: cols 20-24, row 12-14
    _solid_rect(20, 12, 5, 3)

    # Platform A: cols 9-11, row 5 (1 tile tall)
    _solid_rect(9, 5, 3, 1)

    # Platform B: cols 14-16, row 8 (1 tile tall)
    _solid_rect(14, 8, 3, 1)


## Create a StaticBody2D rectangle covering (col, row) for (w x h) tiles.
func _solid_rect(col: int, row: int, w: int, h: int) -> void:
    var body := StaticBody2D.new()
    body.collision_layer = 1   # terrain layer
    body.collision_mask  = 2   # detects player (layer 2)

    var shape := CollisionShape2D.new()
    var rect  := RectangleShape2D.new()
    rect.size = Vector2(w * TILE_SIZE, h * TILE_SIZE)

    shape.shape = rect
    # RectangleShape2D is centred on position; offset so top-left aligns with tile grid
    shape.position = Vector2(
        ROOM_OFFSET.x + col * TILE_SIZE + (w * TILE_SIZE) / 2.0,
        ROOM_OFFSET.y + row * TILE_SIZE + (h * TILE_SIZE) / 2.0
    )

    body.add_child(shape)
    _collision.add_child(body)


# ──────────────────────────────────────────
#  Player
# ──────────────────────────────────────────
func _spawn_player() -> void:
    # Place player so feet sit exactly on top of floor row 12
    # Player CollisionShape2D: RectangleShape2D(12, 32) at position (0, -16)
    # Bottom of collision = -16 + 32/2 = 0 in local space = player.position.y
    # So player.position.y must equal the Y of the top edge of floor row 12
    var floor_top_y := ROOM_OFFSET.y + 12 * TILE_SIZE   # = 45 + 216 = 261
    _spawn_world = Vector2(
        ROOM_OFFSET.x + SPAWN_TILE.x * TILE_SIZE + TILE_SIZE * 0.5,
        floor_top_y   # feet exactly on floor surface
    )

    var scene : PackedScene = load("res://scenes/player.tscn")
    _player = scene.instantiate() as CharacterBody2D
    _player.spawn_position = _spawn_world
    _player.position       = _spawn_world
    add_child(_player)

    _player.died.connect(_on_player_died)
    _player.reached_exit.connect(_on_reached_exit)


func respawn_player() -> void:
    if _player:
        _player.respawn(_spawn_world)


# ──────────────────────────────────────────
#  Event handlers
# ──────────────────────────────────────────
func _on_player_died() -> void:
    GameState.stop_room_timer()
    GameState.lose_life()
    if GameState.lives > 0:
        await get_tree().create_timer(0.7).timeout
        respawn_player()
        GameState.start_room_timer(60.0)


func _on_reached_exit() -> void:
    GameState.stop_room_timer()
    AudioManager.play("stage_clear")
    GameState.add_score(500)
    await get_tree().create_timer(1.0).timeout
    get_tree().reload_current_scene()


func _on_time_up() -> void:
    AudioManager.play("warning")
    if _player:
        _player.die()