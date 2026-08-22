extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Simple floating animation
	var tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var start_pos = $Sprite2D.position
	tween.tween_property($Sprite2D, "position", start_pos + Vector2(0, -3), 1.0)
	tween.tween_property($Sprite2D, "position", start_pos, 1.0)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.has_method("die"):
		AudioManager.play("select", -6.0, 1.5) # Play sound at higher pitch for a "ding"
		GameState.add_score(100)
		queue_free()
