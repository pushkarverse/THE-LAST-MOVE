extends Control

## Main Menu Controller for "The Last Step"

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var prompt_label: Label = $CenterContainer/VBoxContainer/PromptLabel
@onready var subtitle_label: Label = $SubtitleLabel
@onready var particles: CPUParticles2D = $Particles
@onready var bg_rect: ColorRect = $Background

var is_starting: bool = false
var _prompt_tween: Tween
var _title_tween: Tween

func _ready() -> void:
	# Ensure proper display setup
	GameState.set_world_label("1")
	
	# Start idle pulsing animations
	_start_title_animation()
	_start_prompt_animation()
	
	# Play ambient BGM or menu select sound if available
	AudioManager.play("select", -6.0, 0.9)

func _start_title_animation() -> void:
	_title_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_title_tween.tween_property(title_label, "position:y", title_label.position.y - 6.0, 1.4)
	_title_tween.tween_property(title_label, "position:y", title_label.position.y + 6.0, 1.4)

func _start_prompt_animation() -> void:
	_prompt_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_prompt_tween.tween_property(prompt_label, "modulate:a", 0.25, 0.8)
	_prompt_tween.tween_property(prompt_label, "modulate:a", 1.0, 0.8)

func _unhandled_input(event: InputEvent) -> void:
	if is_starting:
		return
	
	# Detect any key, mouse button, or gamepad button
	if event is InputEventKey and event.pressed and not event.is_echo():
		_trigger_start()
	elif event is InputEventMouseButton and event.pressed:
		_trigger_start()
	elif event is InputEventJoypadButton and event.pressed:
		_trigger_start()
	elif event.is_action_pressed("jump") or event.is_action_pressed("ui_confirm") or event.is_action_pressed("ui_accept"):
		_trigger_start()

func _trigger_start() -> void:
	if is_starting:
		return
	is_starting = true
	
	# 1. Stop idle animations
	if _prompt_tween and _prompt_tween.is_running():
		_prompt_tween.kill()
	if _title_tween and _title_tween.is_running():
		_title_tween.kill()
	
	# 2. Play game start sound
	AudioManager.play("stage_clear", 0.0, 1.0)
	
	# 3. Flash & Scale prompt label
	prompt_label.modulate = Color(1.5, 1.5, 0.5, 1.0)
	var tw_prompt = create_tween().set_parallel(true)
	tw_prompt.tween_property(prompt_label, "scale", Vector2(1.2, 1.2), 0.15)
	tw_prompt.tween_property(prompt_label, "modulate:a", 0.0, 0.3).set_delay(0.15)
	
	# 4. Zoom Title slightly & shake effect
	var tw_title = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw_title.tween_property(title_label, "scale", Vector2(1.15, 1.15), 0.4)
	tw_title.tween_property(title_label, "modulate", Color(1.3, 1.3, 1.0, 1.0), 0.3)
	
	# 5. Screen shake simulation on root container
	var tw_shake = create_tween().set_trans(Tween.TRANS_SINE)
	for i in 4:
		tw_shake.tween_property(self, "position", Vector2(randf_range(-4, 4), randf_range(-4, 4)), 0.04)
	tw_shake.tween_property(self, "position", Vector2.ZERO, 0.04)
	
	# 6. Initialize Game State for fresh run
	GameState.reset_run()
	GameState.set_world_label("1")
	
	# 7. Transition to Level 1 using SceneManager
	await get_tree().create_timer(0.4).timeout
	SceneManager.change_scene("res://levels/room_01.tscn", {
		"pattern": "circle",
		"speed": 2.0,
		"wait_time": 0.2
	})
