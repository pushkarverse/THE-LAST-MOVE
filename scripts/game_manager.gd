extends Node

## GameManager — Autoload singleton
## Tracks lives, score, current room index, and handles scene transitions.

# ──────────────────────────────────────────
#  Constants
# ──────────────────────────────────────────
const MAX_LIVES   : int = 3
const DEATH_DELAY : float = 0.8   # seconds before respawn after death

## Ordered list of room scene paths (expand as rooms are built)
const ROOM_SCENES : Array[String] = [
	"res://levels/room_01.tscn",
	"res://levels/room_02.tscn",
	"res://levels/room_03.tscn",
]

## Customizable names for levels (HUD displays these cleanly)
const LEVEL_NAMES : Array[String] = [
	"LEVEL 1",
	"LEVEL 2",
	"LEVEL 3",
]

# ──────────────────────────────────────────
#  Persistent state
# ──────────────────────────────────────────
var lives        : int = MAX_LIVES
var score        : int = 0
var current_room : int = 0   # index into ROOM_SCENES

# ──────────────────────────────────────────
#  Signals (HUD and UI listen to these)
# ──────────────────────────────────────────
signal lives_changed(new_lives: int)
signal score_changed(new_score: int)
signal room_changed(room_index: int)
signal game_over


# ──────────────────────────────────────────
#  Public API
# ──────────────────────────────────────────

## Called when the player dies
func on_player_died() -> void:
	lives -= 1
	emit_signal("lives_changed", lives)
	if lives <= 0:
		emit_signal("game_over")
		await get_tree().create_timer(1.2).timeout
		_reset_game()
		load_current_room()
	else:
		await get_tree().create_timer(DEATH_DELAY).timeout
		_respawn_player()


## Called when the player reaches the exit door
func on_room_complete() -> void:
	score += 500 + (current_room * 200)
	emit_signal("score_changed", score)
	await get_tree().create_timer(0.3).timeout
	advance_room()


func advance_room() -> void:
	current_room += 1
	if current_room >= ROOM_SCENES.size():
		# All rooms complete — loop back for now (replace with end screen later)
		current_room = 0
	emit_signal("room_changed", current_room)
	load_current_room()


func load_current_room() -> void:
	SceneManager.change_scene(ROOM_SCENES[current_room])


func start_game() -> void:
	current_room = 0
	lives = MAX_LIVES
	score = 0
	GameState.reset_run()
	GameState.set_world_label("1")
	load_current_room()


func return_to_menu() -> void:
	current_room = 0
	GameState.reset_run()
	SceneManager.change_scene("res://scenes/main_menu.tscn")


func add_score(amount: int) -> void:
	score += amount
	emit_signal("score_changed", score)


# ──────────────────────────────────────────
#  Internal helpers
# ──────────────────────────────────────────

func _reset_game() -> void:
	lives        = MAX_LIVES
	score        = 0
	current_room = 0
	emit_signal("lives_changed", lives)
	emit_signal("score_changed", score)


func _respawn_player() -> void:
	# Ask the current room to respawn the player at its spawn point
	var room = get_tree().current_scene
	if room and room.has_method("respawn_player"):
		room.respawn_player()
