extends Node2D

@export var title_text: String = "THANK YOU FOR PLAYING!"
@export var team_name: String = "TEAM BINARY BRAINS"
@export var team_members: Array[String] = [
	"ANWESHA MONDAL",
	"DEV KRRISH SINHA",
	"PUSHKAR KUMAR"
]

@onready var door_sprite: Sprite2D = $DoorSprite
@onready var exit_trigger: Area2D = $ExitTrigger
@onready var key_sprite: Sprite2D = $KeySprite

var _exit_started: bool = false

func _ready() -> void:
	# Configure exit trigger collision: layer 0, mask 2 (Player is layer 2)
	exit_trigger.collision_layer = 0
	exit_trigger.collision_mask = 2
	
	# Connect signal
	if not exit_trigger.body_entered.is_connected(_on_exit_trigger_body_entered):
		exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)
	
	# Setup door sprite: closed door (column 10, rows 4-5 in tilemap = Rect2(180, 72, 18, 36))
	door_sprite.region_enabled = true
	door_sprite.region_rect = Rect2(180, 72, 18, 36)
	
	# Setup key sprite: golden key (column 7, row 1 in tilemap = Rect2(126, 18, 18, 18))
	key_sprite.region_enabled = true
	key_sprite.region_rect = Rect2(126, 18, 18, 18)
	key_sprite.visible = false

func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if _exit_started:
		return
	
	# Verify player
	if not (body.is_in_group("player") or body.has_method("die")):
		return
	
	print("LEVEL 3 EXIT: PLAYER DETECTED")
	_exit_started = true
	print("LEVEL 3 EXIT: STARTING SEQUENCE")
	
	_start_exit_sequence(body)

func _start_exit_sequence(player: Node2D) -> void:
	# ─────────────────────────────────────────────────────────────
	# 1. LOCK PLAYER & FREEZE GAME STATE
	# ─────────────────────────────────────────────────────────────
	GameState.stop_room_timer()
	GameState.add_score(500)
	
	# Lock player physics and inputs completely
	if player.has_method("set_physics_process"):
		player.set_physics_process(false)
	if player.has_method("set_process_input"):
		player.set_process_input(false)
	if "velocity" in player:
		player.velocity = Vector2.ZERO
	
	# Disable player collision so hazards/spikes cannot kill or interact during ending
	if "collision_layer" in player:
		player.collision_layer = 0
	if "collision_mask" in player:
		player.collision_mask = 0
	
	# Set player to idle animation
	var player_anim = player.get_node_or_null("AnimatedSprite2D")
	if player_anim and player_anim is AnimatedSprite2D:
		player_anim.play("idle")
	
	# ─────────────────────────────────────────────────────────────
	# 2. SHORT PAUSE
	# ─────────────────────────────────────────────────────────────
	await get_tree().create_timer(0.3).timeout
	
	# ─────────────────────────────────────────────────────────────
	# 3. POKÉMON-STYLE KEY UNLOCK ANIMATION
	# ─────────────────────────────────────────────────────────────
	# Position key near player
	var start_key_pos = player.global_position + Vector2(10, -18)
	var door_lock_pos = door_sprite.global_position + Vector2(0, 2)
	
	key_sprite.global_position = start_key_pos
	key_sprite.scale = Vector2.ZERO
	key_sprite.rotation = 0.0
	key_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	key_sprite.visible = true
	
	# Key appears with spin
	AudioManager.play("select", 0.0, 1.1)
	var tw_key_in = create_tween().set_parallel(true)
	tw_key_in.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw_key_in.tween_property(key_sprite, "scale", Vector2(1.3, 1.3), 0.35)
	tw_key_in.tween_property(key_sprite, "rotation", TAU, 0.35)
	await tw_key_in.finished
	
	# Key moves and turns toward the door lock
	var tw_key_move = create_tween().set_parallel(true)
	tw_key_move.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw_key_move.tween_property(key_sprite, "global_position", door_lock_pos, 0.4)
	tw_key_move.tween_property(key_sprite, "rotation", TAU + PI * 0.5, 0.4)
	await tw_key_move.finished
	
	# Unlock effect: key shakes
	AudioManager.play("select", 3.0, 1.6) # High click
	var tw_key_shake = create_tween().set_trans(Tween.TRANS_SINE)
	for i in 3:
		tw_key_shake.tween_property(key_sprite, "position:x", key_sprite.position.x + 2.0, 0.04)
		tw_key_shake.tween_property(key_sprite, "position:x", key_sprite.position.x - 2.0, 0.04)
	tw_key_shake.tween_property(key_sprite, "position:x", key_sprite.position.x, 0.04)
	await tw_key_shake.finished
	
	# Key disappears into lock
	var tw_key_out = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw_key_out.tween_property(key_sprite, "scale", Vector2.ZERO, 0.2)
	tw_key_out.tween_property(key_sprite, "modulate:a", 0.0, 0.2)
	await tw_key_out.finished
	key_sprite.visible = false
	
	# ─────────────────────────────────────────────────────────────
	# 4. DOOR OPENS
	# ─────────────────────────────────────────────────────────────
	door_sprite.region_rect = Rect2(198, 72, 18, 36) # Open door tile
	AudioManager.play("select", -2.0, 0.7) # Door open sound
	
	await get_tree().create_timer(0.25).timeout
	
	# ─────────────────────────────────────────────────────────────
	# 5. PLAYER ENTERS THE DOOR
	# ─────────────────────────────────────────────────────────────
	if player_anim and player_anim is AnimatedSprite2D:
		player_anim.play("walk")
		player_anim.flip_h = false
	
	var tw_walk = create_tween().set_parallel(true)
	tw_walk.tween_property(player, "global_position:x", global_position.x, 0.6)
	tw_walk.tween_property(player, "scale", Vector2(0.3, 0.3), 0.5).set_delay(0.15)
	if player_anim:
		tw_walk.tween_property(player_anim, "modulate:a", 0.0, 0.45).set_delay(0.15)
	await tw_walk.finished
	
	player.visible = false
	await get_tree().create_timer(0.2).timeout
	
	# ─────────────────────────────────────────────────────────────
	# 6. POKÉMON IRIS BLACK TRANSITION
	# ─────────────────────────────────────────────────────────────
	var layer := CanvasLayer.new()
	layer.layer = 200
	get_tree().root.add_child(layer)
	
	var vp_size = get_viewport_rect().size
	if vp_size.x <= 0 or vp_size.y <= 0:
		vp_size = Vector2(640, 360)
	var screen_center = vp_size / 2.0
	
	# Compute door's screen coordinates for iris center
	var door_screen_pos = get_global_transform_with_canvas().origin + Vector2(0, -18)
	var norm_center = door_screen_pos / vp_size
	
	var iris_rect := ColorRect.new()
	iris_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	iris_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform vec2  center   = vec2(0.5, 0.5);
uniform float radius   : hint_range(0.0, 2.5) = 1.5;
uniform float aspect   = 1.777777;
uniform vec4  bg_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 diff = UV - center;
	diff.x *= aspect;
	float dist = length(diff);
	if (dist < radius) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		COLOR = bg_color;
	}
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("center", norm_center)
	mat.set_shader_parameter("radius", 1.5)
	mat.set_shader_parameter("aspect", vp_size.x / vp_size.y)
	mat.set_shader_parameter("bg_color", Color(0, 0, 0, 1))
	iris_rect.material = mat
	layer.add_child(iris_rect)
	
	AudioManager.play("warning", -6.0, 0.5) # Whoosh effect
	var tw_iris = layer.create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tw_iris.tween_method(func(r: float): mat.set_shader_parameter("radius", r), 1.5, 0.0, 1.4)
	await tw_iris.finished
	
	# Remove shader rect and replace with solid permanent black background
	iris_rect.queue_free()
	var black_bg := ColorRect.new()
	black_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black_bg.color = Color(0, 0, 0, 1)
	black_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(black_bg)
	
	# ─────────────────────────────────────────────────────────────
	# 7. FINAL BLACK SCREEN & CREDITS
	# ─────────────────────────────────────────────────────────────
	await get_tree().create_timer(0.5).timeout
	
	var ui_container := Control.new()
	ui_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(ui_container)
	
	# Title: "THANK YOU FOR PLAYING!"
	var title_lbl := Label.new()
	title_lbl.text = title_text
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_lbl.size = Vector2(vp_size.x, 50)
	title_lbl.position = Vector2(0, screen_center.y - 75)
	title_lbl.pivot_offset = Vector2(vp_size.x / 2.0, 25)
	title_lbl.modulate.a = 0.0
	title_lbl.scale = Vector2(0.7, 0.7)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.2)) # Retro Yellow
	title_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	title_lbl.add_theme_constant_override("outline_size", 6)
	title_lbl.add_theme_font_size_override("font_size", 22)
	ui_container.add_child(title_lbl)
	
	# Team Name
	var team_lbl := Label.new()
	team_lbl.text = team_name
	team_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	team_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	team_lbl.size = Vector2(vp_size.x, 30)
	team_lbl.position = Vector2(0, screen_center.y - 15)
	team_lbl.modulate.a = 0.0
	team_lbl.add_theme_color_override("font_color", Color(0.25, 0.95, 0.35)) # Retro Green
	team_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	team_lbl.add_theme_constant_override("outline_size", 4)
	team_lbl.add_theme_font_size_override("font_size", 14)
	ui_container.add_child(team_lbl)
	
	# Team Members
	var member_labels: Array[Label] = []
	var start_y = screen_center.y + 20
	for i in team_members.size():
		var m_lbl := Label.new()
		m_lbl.text = team_members[i]
		m_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		m_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		m_lbl.size = Vector2(vp_size.x, 24)
		m_lbl.position = Vector2(0, start_y + i * 22)
		m_lbl.modulate.a = 0.0
		m_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95)) # Clean Silver
		m_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		m_lbl.add_theme_constant_override("outline_size", 3)
		m_lbl.add_theme_font_size_override("font_size", 12)
		ui_container.add_child(m_lbl)
		member_labels.append(m_lbl)
	
	AudioManager.play("stage_clear")
	
	# Animate Title
	var tw_title = layer.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw_title.tween_property(title_lbl, "modulate:a", 1.0, 0.6)
	tw_title.tween_property(title_lbl, "scale", Vector2.ONE, 0.6)
	await tw_title.finished
	
	await get_tree().create_timer(0.35).timeout
	
	# Animate Team Name
	var tw_team = layer.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw_team.tween_property(team_lbl, "modulate:a", 1.0, 0.5)
	await tw_team.finished
	
	await get_tree().create_timer(0.25).timeout
	
	# Animate Members in sequence
	for m_lbl in member_labels:
		var tw_m = layer.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw_m.tween_property(m_lbl, "modulate:a", 1.0, 0.4)
		await get_tree().create_timer(0.18).timeout
	
	# Subtle gentle pulse on Title
	var pulse_tw = layer.create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tw.tween_property(title_lbl, "scale", Vector2(1.04, 1.04), 1.2)
	pulse_tw.tween_property(title_lbl, "scale", Vector2(0.98, 0.98), 1.2)
	
	# Sequence stays on screen indefinitely (no reload, no scene transition)
