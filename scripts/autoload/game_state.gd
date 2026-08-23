extends Node
## Global game state singleton (registered as the autoload "GameState").
##
## Tracks lives, score, coins, the current room and the per-room timer.
## It emits signals that the HUD listens to, so the UI never has to reach
## into game logic directly. Any script can read/write it, e.g.
##     GameState.add_coin()
##     GameState.lose_life()

signal lives_changed(lives: int)
signal score_changed(score: int)
signal coins_changed(coins: int)
signal time_changed(seconds: float)
signal world_label_changed(new_label: String)
signal time_up()          ## The per-room timer hit zero. The room decides what happens.
signal game_over()        ## Lives reached zero.

const START_LIVES: int = 3
const DEFAULT_ROOM_TIME: float = 60.0

var lives: int = START_LIVES
var score: int = 0
var coins: int = 0
var world_label: String = "1"

# Per-room countdown. Rooms are designed to last under ~60 seconds.
var time_left: float = DEFAULT_ROOM_TIME
var _timer_running: bool = false

func _ready() -> void:
	game_over.connect(_on_game_over)

func _on_game_over() -> void:
	pass # HUD handles the game over screen and restart

func _process(delta: float) -> void:
	if not _timer_running:
		return
	time_left = max(0.0, time_left - delta)
	time_changed.emit(time_left)
	if time_left <= 0.0:
		_timer_running = false
		time_up.emit()


## Call once when a fresh run begins (from the title screen or after game over).
func reset_run() -> void:
	lives = START_LIVES
	score = 0
	coins = 0
	lives_changed.emit(lives)
	score_changed.emit(score)
	coins_changed.emit(coins)


func start_room_timer(seconds: float = DEFAULT_ROOM_TIME) -> void:
	time_left = seconds
	_timer_running = true
	time_changed.emit(time_left)


func stop_room_timer() -> void:
	_timer_running = false


func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)


func add_coin(amount: int = 1) -> void:
	coins += amount
	coins_changed.emit(coins)
	add_score(amount * 100)


func lose_life() -> void:
	lives = max(0, lives - 1)
	
	# Death Penalty
	score = max(0, score - 100)
	score_changed.emit(score)
	
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()


func set_world_label(label: String) -> void:
	world_label = label
	world_label_changed.emit(world_label)
