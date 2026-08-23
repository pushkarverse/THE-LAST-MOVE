extends Node2D
## Room 03 — Dark Castle Level (Level 3)
## Layout is fully baked into room_03.tscn and editable in the Godot 2D editor.

@export var next_scene_path: String = ""   ## Set in Inspector to wire to Level 4 when ready.

var _player      : CharacterBody2D
var _spawn_world : Vector2

func _ready() -> void:
	_spawn_player()
	GameState.start_room_timer(120.0)
	GameState.set_world_label("3")
	GameState.time_up.connect(_on_time_up)

func _spawn_player() -> void:
	var spawn_node = get_node_or_null("PlayerSpawn")
	if spawn_node:
		_spawn_world = spawn_node.position
	else:
		_spawn_world = Vector2(63, 468)

	var scene : PackedScene = load("res://scenes/player.tscn")
	_player = scene.instantiate() as CharacterBody2D
	_player.spawn_position = _spawn_world
	_player.position       = _spawn_world
	add_child(_player)
	_player.died.connect(_on_player_died)
	_player.reached_exit.connect(_on_reached_exit)

	# Override camera limits for this taller, wider level
	var cam = _player.get_node_or_null("Camera2D")
	if cam:
		cam.limit_right  = 1368
		cam.limit_bottom = 576
		cam.limit_left   = 0
		cam.limit_top    = -200

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
	if next_scene_path != "" and FileAccess.file_exists(next_scene_path):
		SceneManager.change_scene(next_scene_path)
	else:
		SceneManager.reload_scene()

func _on_time_up() -> void:
	AudioManager.play("warning")
	if _player: _player.die()
