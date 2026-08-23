extends CanvasLayer

@export var hell_transition_scene: PackedScene

@onready var color_rect = $ColorRect
@onready var devil_sprite = $DevilSprite
@onready var dialog_label = $DialogPanel/DialogLabel
@onready var dialog_panel = $DialogPanel
@onready var coin_sprite = $CoinSprite
@onready var heads_label = $HBoxContainer/HeadsLabel
@onready var tails_label = $HBoxContainer/TailsLabel
@onready var timer_label = $TimerLabel

var state: int = 0 # 0=Dialog, 1=Choice, 2=Tossing, 3=Result
var dialog_step: int = 0
var choices = ["HEADS", "TAILS"]
var selected_choice: String = "HEADS"
var time_left: float = 5.0

func _ready() -> void:
	devil_sprite.modulate.a = 0.0
	heads_label.modulate.a = 0.0
	tails_label.modulate.a = 0.0
	coin_sprite.modulate.a = 0.0
	timer_label.text = ""
	dialog_label.text = ""
	dialog_panel.modulate.a = 0.0
	
	_play_sequence()

func _play_sequence() -> void:
	AudioManager.play("warning") # Ominous
	
	var tw = create_tween()
	tw.tween_property(devil_sprite, "modulate:a", 1.0, 1.0)
	tw.tween_callback(func(): _show_dialog("Welcome..."))
	tw.tween_interval(1.5)
	tw.tween_callback(func(): _show_dialog("You want to pass?"))
	tw.tween_interval(1.5)
	tw.tween_callback(func(): _show_dialog("Then fate will decide."))
	tw.tween_interval(1.5)
	tw.tween_callback(func(): _show_dialog("HEADS or TAILS?"))
	tw.tween_callback(_start_choice).set_delay(1.0)

func _show_dialog(text: String) -> void:
	if text == "":
		dialog_panel.modulate.a = 0.0
	else:
		dialog_panel.modulate.a = 1.0
	dialog_label.text = text

func _start_choice() -> void:
	state = 1
	var tw = create_tween().set_parallel(true)
	tw.tween_property(heads_label, "modulate:a", 1.0, 0.5)
	tw.tween_property(tails_label, "modulate:a", 1.0, 0.5)
	tw.tween_property(coin_sprite, "modulate:a", 1.0, 0.5)
	_update_highlight()

func _update_highlight() -> void:
	if selected_choice == "HEADS":
		heads_label.add_theme_color_override("font_color", Color.YELLOW)
		tails_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		heads_label.add_theme_color_override("font_color", Color.WHITE)
		tails_label.add_theme_color_override("font_color", Color.YELLOW)

func _process(delta: float) -> void:
	if state == 1:
		time_left -= delta
		timer_label.text = str(ceil(time_left))
		
		if time_left <= 0:
			_resolve_toss(true) # Timeout = Loss
			return
			
		if Input.is_action_just_pressed("ui_left"):
			selected_choice = "HEADS"
			AudioManager.play("menu-select")
			_update_highlight()
		elif Input.is_action_just_pressed("ui_right"):
			selected_choice = "TAILS"
			AudioManager.play("menu-select")
			_update_highlight()
			
		if Input.is_action_just_pressed("ui_accept"):
			_resolve_toss(false)

func _resolve_toss(timeout: bool) -> void:
	state = 2
	timer_label.text = ""
	AudioManager.play("action-press-button-2")
	
	if timeout:
		_show_dialog("TIME'S UP.")
		_do_loss()
		return
		
	_show_dialog("")
	# 40/60 logic (40% win, 60% loss)
	var is_win = (randf() <= 0.40)
	var final_coin_result = selected_choice if is_win else ("TAILS" if selected_choice == "HEADS" else "HEADS")
	
	# Coin toss animation
	var tw = create_tween()
	var base_y = coin_sprite.position.y
	tw.tween_property(coin_sprite, "position:y", base_y - 100, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_callback(func(): AudioManager.play("menu-select"))
	tw.tween_property(coin_sprite, "position:y", base_y, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	var rot_tw = create_tween().set_loops(5)
	rot_tw.tween_property(coin_sprite, "scale:y", 0.0, 0.1)
	rot_tw.tween_property(coin_sprite, "scale:y", 1.0, 0.1)
	
	tw.tween_callback(func():
		AudioManager.play("stage-clear-8-bit")
		# Set final visual
		coin_sprite.scale.y = 1.0
		# Swap texture based on result (assume we preload textures or just use logic)
		# For simplicity, we just use labels or color on the coin.
		if final_coin_result == "HEADS":
			coin_sprite.modulate = Color.RED
		else:
			coin_sprite.modulate = Color.BLUE
	)
	
	tw.tween_interval(1.0)
	if is_win:
		tw.tween_callback(_do_win)
	else:
		tw.tween_callback(_do_loss)

func _do_win() -> void:
	state = 3
	_show_dialog("YOU MAY PASS.")
	AudioManager.play("stage-clear-8-bit")
	await get_tree().create_timer(2.0).timeout
	# Transition to next stage. For now, reload or print
	get_tree().reload_current_scene()

func _do_loss() -> void:
	state = 3
	_show_dialog("YOU LOSE.")
	AudioManager.play("warning")
	await get_tree().create_timer(1.0).timeout
	
	if hell_transition_scene:
		var ht = hell_transition_scene.instantiate()
		get_tree().root.add_child(ht)
	queue_free()
