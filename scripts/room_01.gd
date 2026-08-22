extends Node2D
## Room 01 - Redesigned Complete Level
## The layout is visually editable in the Godot Editor.

var _player      : CharacterBody2D
var _spawn_world : Vector2

func _ready() -> void:
	_spawn_player()
	GameState.start_room_timer(120.0)
	GameState.set_world_label("1-1")
	GameState.time_up.connect(_on_time_up)

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
