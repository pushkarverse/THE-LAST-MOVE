extends Node2D
## Room 02 - Redesigned Complete Level
## The layout is visually editable in the Godot Editor.

var _player      : CharacterBody2D
var _spawn_world : Vector2

func _ready() -> void:
	_spawn_player()
	GameState.start_room_timer(120.0)
	GameState.set_world_label("2")
	GameState.time_up.connect(_on_time_up)
	
	# Start normal background music (fades in).
	# Note: Replace this path with the actual BGM file if it differs.
	AudioManager.play_music("res://audio/music/bgm.ogg", 1.5)
	
	_generate_terrain()

func _generate_terrain() -> void:
	var terrain = get_node_or_null("Terrain")
	if not terrain: return
	
	terrain.clear() # Clear any old tiles saved in the scene file
	
	# The Atlas IDs for Snow Blocks in the tileset (0 is the source ID)
	var top_stone = Vector2i(1, 4)
	var mid_stone = Vector2i(1, 5)
	
	# Helper function to paint rectangular blocks of terrain and create collision
	var add_box = func(x1: int, x2: int, y1: int, y2: int):
		for x in range(x1, x2):
			for y in range(y1, y2):
				terrain.set_cell(Vector2i(x, y), 0, mid_stone)
			terrain.set_cell(Vector2i(x, y1-1), 0, top_stone)
			
		# Generate Collision
		var body = StaticBody2D.new()
		var shape_node = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		
		# tile size is 18x18
		var w = (x2 - x1) * 18.0
		var h = (y2 - (y1 - 1)) * 18.0
		rect.size = Vector2(w, h)
		shape_node.shape = rect
		
		# set position to center of the box
		body.position = Vector2(x1 * 18.0 + w / 2.0, (y1 - 1) * 18.0 + h / 2.0)
		
		body.add_child(shape_node)
		terrain.add_child(body)

	# Build a wide staircase layout
	add_box.call(-5, 15, 12, 20)    # Starting platform (Ground at y=11, 198)
	add_box.call(18, 23, 11, 20)    # Step 1 (5 tiles wide, Ground at y=10, 180)
	add_box.call(26, 31, 9, 20)     # Step 2 (5 tiles wide, Ground at y=8, 144)
	add_box.call(34, 39, 7, 20)     # Step 3 (5 tiles wide, Ground at y=6, 108)
	add_box.call(44, 75, 12, 20)    # Final platform for the Gate (Ground at y=11, 198)


func _spawn_player() -> void:
	var spawn_node = get_node_or_null("PlayerSpawn")
	if spawn_node:
		_spawn_world = spawn_node.position
	else:
		_spawn_world = Vector2(45, 234) # Fallback

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
	GameState.stop_room_timer()
	GameState.lose_life()
	if GameState.lives > 0:
		await get_tree().create_timer(0.7).timeout
		respawn_player()
		GameState.start_room_timer(120.0)

func _on_reached_exit() -> void:
	GameState.stop_room_timer()
	AudioManager.play("stage_clear")
	GameState.add_score(500)
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func _on_time_up() -> void:
	AudioManager.play("warning")
	if _player: _player.die()
