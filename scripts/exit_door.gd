extends Area2D

var _triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _triggered: return
	if not (body.has_method("die") or body.is_in_group("player")):
		return

	_triggered = true

	# 1. Open door sprite (next tile over in spritesheet)
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.region_rect = Rect2(198, 72, 18, 36)
	AudioManager.play("select", -2.0, 0.7)

	# 2. Player walks into door
	if body.has_method("set_physics_process"):
		body.set_physics_process(false)
	var anim = body.get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.play("walk")

	var tw = create_tween().set_parallel(true)
	tw.tween_property(body, "global_position:x", global_position.x, 0.6)
	if anim:
		tw.tween_property(anim, "modulate:a", 0.0, 0.5).set_delay(0.1)
		tw.tween_property(body, "scale", Vector2(0.5, 0.5), 0.5).set_delay(0.1)

	await tw.finished

	# 3. Play cinematic
	var overlay_script = load("res://scripts/level_complete_overlay.gd")
	if overlay_script:
		overlay_script.play(body, get_tree())
		await get_tree().create_timer(4.5).timeout

	# 4. Trigger next scene
	if body.has_user_signal("reached_exit"):
		body.emit_signal("reached_exit")
	elif body.has_method("reached_exit_door"):
		body.reached_exit_door()
