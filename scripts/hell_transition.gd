extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var player_sprite = $PlayerSprite

func _ready() -> void:
	AudioManager.play("damage") # Ominous impact
	
	# Start with black
	color_rect.color = Color.BLACK
	
	# Shake effect (simulate screen shake)
	var tw = create_tween()
	tw.tween_property(color_rect, "position", Vector2(10, 10), 0.05)
	tw.tween_property(color_rect, "position", Vector2(-10, -10), 0.05)
	tw.tween_property(color_rect, "position", Vector2(10, -10), 0.05)
	tw.tween_property(color_rect, "position", Vector2(0, 0), 0.05)
	
	tw.tween_interval(0.5)
	
	# Fade to Hell red
	tw.tween_property(color_rect, "color", Color(0.3, 0.0, 0.0, 1.0), 1.0)
	tw.tween_callback(func(): AudioManager.play("warning")) # Deep rumble replacement
	
	# Fall player
	tw.tween_callback(func():
		player_sprite.position = Vector2(320, -50)
		player_sprite.rotation_degrees = 180 # Make character fall upside down
		player_sprite.visible = true
	)
	tw.tween_property(player_sprite, "position:y", 400.0, 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	tw.tween_callback(_trigger_death)

func _trigger_death() -> void:
	AudioManager.play("death")
	
	# Fade back to black for actual Game Over screen
	var tw = create_tween()
	tw.tween_property(color_rect, "color", Color.BLACK, 0.5)
	
	tw.tween_callback(func():
		GameState.game_over.emit()
		queue_free()
	)
