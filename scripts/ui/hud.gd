extends CanvasLayer

var _hearts: Array[Label] = []
var _score_label: Label
var _level_label: Label
var _grayscale_rect: ColorRect
var _game_over_container: Control
var _is_game_over: bool = false

func _ready() -> void:
	layer = 100 # Put HUD on top
	
	# 1. Grayscale Overlay
	_grayscale_rect = ColorRect.new()
	_grayscale_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_grayscale_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;
	uniform float weight : hint_range(0.0, 1.0) = 0.0;
	uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
	void fragment() {
		vec4 color = texture(screen_texture, SCREEN_UV);
		float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
		COLOR.rgb = mix(color.rgb, vec3(gray), weight);
		COLOR.a = color.a;
	}
	"""
	mat.shader = shader
	mat.set_shader_parameter("weight", 0.0)
	_grayscale_rect.material = mat
	add_child(_grayscale_rect)
	
	# 2. Top HUD Layout
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	add_child(margin)
	
	var hbox = HBoxContainer.new()
	margin.add_child(hbox)
	
	# Hearts Box
	var hearts_box = HBoxContainer.new()
	hearts_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(hearts_box)
	
	for i in 3:
		var h = Label.new()
		h.text = "♥"
		h.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		h.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		h.add_theme_constant_override("outline_size", 4)
		# Set pivot to center for scaling animation
		h.pivot_offset = Vector2(8, 8)
		hearts_box.add_child(h)
		_hearts.append(h)
	
	# Level Label
	_level_label = Label.new()
	_level_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_level_label.add_theme_color_override("font_outline_color", Color(0,0,0))
	_level_label.add_theme_constant_override("outline_size", 4)
	hbox.add_child(_level_label)
	
	# Score Label
	_score_label = Label.new()
	_score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_score_label.add_theme_color_override("font_outline_color", Color(0,0,0))
	_score_label.add_theme_constant_override("outline_size", 4)
	# Center pivot for scale pop
	_score_label.pivot_offset = Vector2(50, 10) 
	hbox.add_child(_score_label)
	
	# 3. Game Over Screen
	_game_over_container = VBoxContainer.new()
	_game_over_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_game_over_container.modulate.a = 0.0 # hidden
	add_child(_game_over_container)
	
	var go_lbl = Label.new()
	go_lbl.text = "GAME OVER"
	go_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_lbl.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	go_lbl.add_theme_color_override("font_outline_color", Color(0,0,0))
	go_lbl.add_theme_constant_override("outline_size", 6)
	_game_over_container.add_child(go_lbl)
	
	var retry_lbl = Label.new()
	retry_lbl.text = "Press R to Retry"
	retry_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	retry_lbl.add_theme_color_override("font_outline_color", Color(0,0,0))
	retry_lbl.add_theme_constant_override("outline_size", 4)
	_game_over_container.add_child(retry_lbl)
	
	# Connect to GameState
	GameState.lives_changed.connect(_on_lives_changed)
	GameState.score_changed.connect(_on_score_changed)
	GameState.game_over.connect(_on_game_over)
	
	# Initial Setup
	_update_hud()
	
func _update_hud() -> void:
	_level_label.text = "LEVEL: %s" % GameState.world_label
	_score_label.text = "SCORE: %04d" % GameState.score
	for i in _hearts.size():
		_hearts[i].modulate.a = 1.0 if i < GameState.lives else 0.0

func _on_lives_changed(lives: int) -> void:
	if lives < _hearts.size() and lives >= 0:
		var h = _hearts[lives]
		if h.modulate.a > 0: # It was visible
			var tw = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			tw.tween_property(h, "scale", Vector2(1.5, 1.5), 0.2)
			tw.tween_property(h, "scale", Vector2(0.5, 0.5), 0.2)
			tw.tween_property(h, "modulate:a", 0.0, 0.1)

func _on_score_changed(score: int) -> void:
	_score_label.text = "SCORE: %04d" % score
	# Pop animation
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_score_label.scale = Vector2(1.3, 1.3)
	tw.tween_property(_score_label, "scale", Vector2.ONE, 0.3)

func _on_game_over() -> void:
	_is_game_over = true
	AudioManager.stop_music(1.2) # Fade out BGM
	AudioManager.play("world_clear", -3.0, 0.6) # Pitched down sad sound
	# Fade to grayscale
	var tw = create_tween().set_parallel(true)
	tw.tween_method(set_grayscale_weight, 0.0, 1.0, 1.2)
	tw.tween_property(_game_over_container, "modulate:a", 1.0, 1.2)


func set_grayscale_weight(weight: float) -> void:
	_grayscale_rect.material.set_shader_parameter("weight", weight)

func _input(event: InputEvent) -> void:
	if _is_game_over and event is InputEventKey and event.pressed and event.keycode == KEY_R:
		_is_game_over = false
		AudioManager.stop_all() # Stop Game Over sound immediately
		GameState.reset_run()
		get_tree().reload_current_scene()

