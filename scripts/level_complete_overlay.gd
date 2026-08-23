extends Node

const TEAM_NAME = "TEAM BINARY BRAINS"
const TEAM_MEMBERS = "ANWESHA MONDAL  ·  DEV KRRISH SINHA  ·  PUSHKAR KUMAR"
## Called by room scripts after the exit door triggers.
## Plays: key unlock spin → player walk-in → Pokémon iris close → black screen → "LEVEL COMPLETE"
##
## Usage:
##   LevelCompleteOverlay.play(player_node, get_tree())

static func play(player: Node2D, scene_tree: SceneTree) -> void:
	# Build the overlay on the root so it survives scene changes
	var root = scene_tree.root

	var layer := CanvasLayer.new()
	layer.layer = 250
	root.add_child(layer)

	var vp_size = scene_tree.root.get_viewport().get_visible_rect().size
	var center  = vp_size / 2.0

	# ─── 1. Freeze player ───────────────────────────────────────
	if player and player.has_method("set_physics_process"):
		player.set_physics_process(false)

	# ─── 2. Key icon spins in ───────────────────────────────────
	var key_lbl := Label.new()
	key_lbl.text = "🗝"
	key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	key_lbl.size = Vector2(120, 120)
	key_lbl.position = center - Vector2(60, 60)
	key_lbl.pivot_offset = Vector2(60, 60)
	key_lbl.scale = Vector2(0, 0)
	key_lbl.modulate = Color(1, 0.85, 0.1)
	key_lbl.add_theme_color_override("font_outline_color", Color(0.3, 0.15, 0))
	key_lbl.add_theme_constant_override("outline_size", 6)
	layer.add_child(key_lbl)

	# Spin key in
	AudioManager.play("select", 0.0, 0.9)
	var tw1 = layer.create_tween().set_parallel(true)
	tw1.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw1.tween_property(key_lbl, "scale",    Vector2(1.4, 1.4), 0.4)
	tw1.tween_property(key_lbl, "rotation", TAU * 1.5, 0.5)
	await tw1.finished

	# Shake the key
	var tw1b = layer.create_tween().set_trans(Tween.TRANS_SINE)
	for _i in 4:
		tw1b.tween_property(key_lbl, "position:x", center.x - 52, 0.05)
		tw1b.tween_property(key_lbl, "position:x", center.x - 68, 0.05)
	tw1b.tween_property(key_lbl, "position:x", center.x - 60, 0.05)
	await tw1b.finished

	AudioManager.play("select", 3.0, 1.6)   # higher "click"

	# Key shrinks and flies upward (unlocked!)
	var tw1c = layer.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw1c.tween_property(key_lbl, "scale",    Vector2(0, 0), 0.3)
	tw1c.tween_property(key_lbl, "position:y", center.y - 120, 0.3)
	tw1c.tween_property(key_lbl, "modulate:a", 0.0, 0.25)
	await tw1c.finished
	key_lbl.queue_free()

	# Small pause — door opens
	await scene_tree.create_timer(0.2).timeout

	# ─── 3. Pokémon iris close ───────────────────────────────────
	# Strategy: draw a black ColorRect covering everything, then mask
	# a shrinking circle by drawing a TextureRect over it using a
	# simple shader that punches a circular hole which we shrink to 0.
	#
	# We use a ShaderMaterial on a full-screen ColorRect.
	# The circle center is the player's screen position.

	# Get player screen pos
	var player_screen_pos = center   # fallback
	if player and is_instance_valid(player):
		var cam = player.get_node_or_null("Camera2D")
		if cam:
			player_screen_pos = vp_size / 2.0  # camera always centers on player
		else:
			player_screen_pos = player.get_global_transform_with_canvas().origin

	var iris_rect := ColorRect.new()
	iris_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	iris_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform vec2  center    = vec2(0.5, 0.5);
uniform float radius    : hint_range(0.0, 2.0) = 1.0;
uniform vec4  bg_color  : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 uv   = UV;
	vec2 diff = uv - center;
	// Correct for non-square viewports
	diff.x *= (1.0 / (1.0 / (SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x)));
	float dist = length(diff);
	if (dist < radius) {
		// Inside circle: transparent (show game)
		COLOR = vec4(0.0);
	} else {
		COLOR = bg_color;
	}
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("center", player_screen_pos / vp_size)
	mat.set_shader_parameter("radius", 1.5)
	mat.set_shader_parameter("bg_color", Color(0, 0, 0, 1))
	iris_rect.material = mat
	layer.add_child(iris_rect)

	# Animate radius from 1.5 → 0
	AudioManager.play("warning", -6.0, 0.5)   # soft whoosh
	var iris_tw = layer.create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	iris_tw.tween_method(
		func(r: float): mat.set_shader_parameter("radius", r),
		1.5, 0.0, 0.85
	)
	await iris_tw.finished

	# Fully black now — remove shader rect, add solid black instead
	iris_rect.queue_free()
	var black_bg := ColorRect.new()
	black_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black_bg.color = Color(0, 0, 0, 1)
	black_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(black_bg)

	await scene_tree.create_timer(0.4).timeout

	# ─── 4. "THANK YOU FOR PLAYING!" text ────────────────────────────────
	var complete_lbl := Label.new()
	complete_lbl.text = "THANK YOU FOR PLAYING!"
	complete_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	complete_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	complete_lbl.size = Vector2(vp_size.x, 60)
	complete_lbl.position = Vector2(0, center.y - 70)
	complete_lbl.modulate.a = 0.0
	complete_lbl.scale = Vector2(0.8, 0.8)
	complete_lbl.pivot_offset = Vector2(vp_size.x / 2.0, 30)
	complete_lbl.add_theme_color_override("font_color",         Color(1, 0.92, 0.2))
	complete_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	complete_lbl.add_theme_constant_override("outline_size", 6)
	layer.add_child(complete_lbl)

	# ─── 5. Team Credits ────────────────────────────────────────
	var team_lbl := Label.new()
	team_lbl.text = TEAM_NAME
	team_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	team_lbl.size = Vector2(vp_size.x, 40)
	team_lbl.position = Vector2(0, center.y - 10)
	team_lbl.modulate.a = 0.0
	team_lbl.add_theme_color_override("font_color",         Color(0.2, 0.9, 0.2)) # Green
	team_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	team_lbl.add_theme_constant_override("outline_size", 4)
	layer.add_child(team_lbl)
	
	var members_lbl := Label.new()
	members_lbl.text = TEAM_MEMBERS
	members_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	members_lbl.size = Vector2(vp_size.x, 40)
	members_lbl.position = Vector2(0, center.y + 20)
	members_lbl.modulate.a = 0.0
	members_lbl.add_theme_color_override("font_color",         Color(0.8, 0.8, 0.8)) # Grey/White
	members_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	members_lbl.add_theme_constant_override("outline_size", 4)
	# Make members text a bit smaller
	members_lbl.scale = Vector2(0.6, 0.6)
	members_lbl.pivot_offset = Vector2(vp_size.x / 2.0, 20)
	layer.add_child(members_lbl)

	AudioManager.play("stage_clear")

	# Animate all text fading in
	var tw_text = layer.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw_text.tween_property(complete_lbl, "modulate:a", 1.0, 0.5)
	tw_text.tween_property(complete_lbl, "scale", Vector2(1.0, 1.0), 0.5)
	
	await scene_tree.create_timer(0.8).timeout
	var tw_team = layer.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw_team.tween_property(team_lbl, "modulate:a", 1.0, 0.6)
	
	await scene_tree.create_timer(0.6).timeout
	var tw_members = layer.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw_members.tween_property(members_lbl, "modulate:a", 1.0, 0.6)

	# Hold for a few seconds then let the room handle the scene change
	await scene_tree.create_timer(4.5).timeout
