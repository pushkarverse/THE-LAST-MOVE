extends Area2D

var collected := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	if not body.is_in_group("player"):
		return

	if not body.is_connected("died", _on_player_died):
		body.died.connect(_on_player_died)

	collected = true
	body.has_double_jump = true

	# Disable collision immediately so it can't trigger twice
	$CollisionShape2D.set_deferred("disabled", true)

	# Get screen position of this box for the icon spawn origin
	var cam : Camera2D = body.get_node_or_null("Camera2D")
	var screen_origin : Vector2
	if cam:
		var world_pos = global_position
		var cam_pos   = cam.get_screen_center_position()
		var viewport_size = get_viewport().get_visible_rect().size
		screen_origin = viewport_size / 2.0 + (world_pos - cam_pos)
	else:
		screen_origin = get_viewport().get_visible_rect().size / 2.0

	# Shatter the box
	_shatter_self()

	# Launch the cinematic
	await get_tree().create_timer(0.12).timeout
	_spawn_powerup_overlay(screen_origin)

# ──────────────────────────────────────────
#  Reset on Player Death
# ──────────────────────────────────────────
func _on_player_died() -> void:
	collected = false
	$CollisionShape2D.set_deferred("disabled", false)
	show()
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color.WHITE
		sprite.scale = Vector2.ONE

# ──────────────────────────────────────────
#  Box shatter animation
# ──────────────────────────────────────────
func _shatter_self() -> void:
	AudioManager.play("select", 3.0, 0.6)  # low thud
	# Flash white then explode outward
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		hide()
		return
	var tw = create_tween().set_parallel(true)
	tw.tween_property(sprite, "modulate", Color(5, 5, 5, 1), 0.05)   # white flash
	tw.tween_property(sprite, "scale", Vector2(1.6, 0.3), 0.08)
	await tw.finished
	var tw2 = create_tween().set_parallel(true)
	tw2.tween_property(sprite, "scale", Vector2(0, 0), 0.15)
	tw2.tween_property(sprite, "modulate:a", 0.0, 0.12)
	await tw2.finished
	hide()

# ──────────────────────────────────────────
#  Cinematic overlay
# ──────────────────────────────────────────
func _spawn_powerup_overlay(spawn_screen_pos: Vector2) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var center = viewport_size / 2.0

	# --- Root CanvasLayer (draws on top of everything) ---
	var layer := CanvasLayer.new()
	layer.layer = 200
	get_tree().root.add_child(layer)

	# --- Dark vignette background (flash in, fade out) ---
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(bg)

	# --- Glow ring ---
	var glow := ColorRect.new()
	var glow_size = 320.0
	glow.size = Vector2(glow_size, glow_size)
	glow.position = center - Vector2(glow_size, glow_size) / 2.0
	glow.color = Color(0.2, 0.5, 1.0, 0)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(glow)

	# --- Icon ---
	var icon_tex = load("res://assets/ui/double_jump_icon.jpg")
	var icon := TextureRect.new()
	icon.texture = icon_tex
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var icon_size = 160.0
	icon.size = Vector2(icon_size, icon_size)
	icon.position = spawn_screen_pos - Vector2(icon_size, icon_size) / 2.0
	icon.scale = Vector2(0.1, 0.1)
	icon.pivot_offset = Vector2(icon_size, icon_size) / 2.0
	icon.modulate = Color(1, 1, 1, 0)
	layer.add_child(icon)

	# --- Text label ---
	var label := Label.new()
	label.text = "⚡ DOUBLE JUMP UNLOCKED! ⚡"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(viewport_size.x, 60)
	label.position = Vector2(0, center.y + 100)
	label.modulate = Color(1, 1, 1, 0)
	label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 6)
	label.scale = Vector2(0.5, 0.5)
	label.pivot_offset = Vector2(viewport_size.x / 2.0, 30)
	layer.add_child(label)

	# ═══════════════════════════════════════
	#  PHASE 1: Flash + icon zoom to center (0 → 0.5s)
	# ═══════════════════════════════════════
	AudioManager.play("select", 2.0, 1.8)   # high "ding!"

	var p1 = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	# BG flash
	p1.tween_property(bg, "color:a", 0.55, 0.15)
	# Icon: fly from spawn_pos to center, scale from tiny to big
	p1.tween_property(icon, "position",
		center - Vector2(icon_size, icon_size) / 2.0, 0.45)
	p1.tween_property(icon, "scale", Vector2(1.5, 1.5), 0.45)
	p1.tween_property(icon, "modulate:a", 1.0, 0.2)
	# Glow ring swells in
	p1.tween_property(glow, "color:a", 0.35, 0.3)
	await p1.finished

	# ═══════════════════════════════════════
	#  PHASE 2: Punch-in overshoot, icon settles (0.5 → 0.7s)
	# ═══════════════════════════════════════
	AudioManager.play("select", 0.0, 1.5)
	var p2 = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	p2.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.25)
	p2.tween_property(glow, "color:a", 0.55, 0.2)
	await p2.finished

	# ═══════════════════════════════════════
	#  PHASE 3: Text slides up + bounce  (0.7 → 1.1s)
	# ═══════════════════════════════════════
	var text_target_y = center.y + 95.0
	var p3 = create_tween().set_parallel(true)
	p3.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	p3.tween_property(label, "scale", Vector2(1.0, 1.0), 0.35)
	p3.tween_property(label, "modulate:a", 1.0, 0.25)
	p3.tween_property(label, "position:y", text_target_y, 0.35)
	await p3.finished

	# ═══════════════════════════════════════
	#  PHASE 4: Idle pulse on icon + glow  (1.1 → 1.9s)
	# ═══════════════════════════════════════
	var pulse = create_tween().set_loops(3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(icon, "scale", Vector2(1.1, 1.1), 0.18)
	pulse.tween_property(icon, "scale", Vector2(0.95, 0.95), 0.18)
	pulse.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.08)
	await get_tree().create_timer(0.85).timeout
	pulse.kill()

	# ═══════════════════════════════════════
	#  PHASE 5: Everything swooshes out  (1.9 → 2.6s)
	# ═══════════════════════════════════════
	var p5 = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	p5.tween_property(icon, "scale", Vector2(0, 0), 0.3)
	p5.tween_property(icon, "modulate:a", 0.0, 0.25)
	p5.tween_property(label, "modulate:a", 0.0, 0.3)
	p5.tween_property(label, "scale", Vector2(2.0, 2.0), 0.3)
	p5.tween_property(bg, "color:a", 0.0, 0.35)
	p5.tween_property(glow, "color:a", 0.0, 0.3)
	await p5.finished

	layer.queue_free()
