extends Area2D

## Gate of Fate Cinematic Trigger
## Handles the key animation and triggers the Coin Toss Cinematic

@export var coin_toss_scene: PackedScene

var _triggered: bool = false
var _player: Node2D

@onready var sprite = $Sprite2D
@onready var key_sprite = $KeySprite
@onready var canvas_layer = $CanvasLayer
@onready var color_rect = $CanvasLayer/ColorRect

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	key_sprite.visible = false
	color_rect.color.a = 0.0
	
func _on_body_entered(body: Node2D) -> void:
	if _triggered or not body.name.begins_with("Player"):
		return
		
	_triggered = true
	_player = body
	
	# Disable player movement and stop run animation
	if _player.has_method("set_physics_process"):
		_player.set_physics_process(false)
	if _player.has_node("AnimatedSprite2D"):
		_player.get_node("AnimatedSprite2D").play("idle")
	# Turn player towards gate if needed
	if _player.has_node("AnimatedSprite2D"):
		_player.get_node("AnimatedSprite2D").flip_h = false

		
	_start_cinematic()

func _start_cinematic() -> void:
	# 1. Spawn key near player's pocket globally
	key_sprite.global_position = _player.global_position + Vector2(-5, 5)
	key_sprite.visible = true
	
	# Rustle sound
	AudioManager.play("menu-select") # Reusing subtle sound
	
	var tw = create_tween()
	
	# 2. Key moves up to hand
	tw.tween_property(key_sprite, "global_position", _player.global_position + Vector2(8, -5), 0.5)
	
	# 3. Key moves to lock
	var lock_pos = global_position + Vector2(16, -24) # Adjust based on door sprite
	tw.tween_property(key_sprite, "global_position", lock_pos, 0.5).set_delay(0.2)
	
	# 4. Insert sound
	tw.tween_callback(func(): AudioManager.play("action-press-button-2"))
	
	# 5. Turn key
	tw.tween_property(key_sprite, "rotation_degrees", 90.0, 0.3).set_delay(0.2)
	
	# 6. Click sound
	tw.tween_callback(func(): AudioManager.play("unlock"))
	
	# 7. Gate open visually & sound
	tw.tween_callback(_open_gate).set_delay(0.2)
	
	# 8. Player walks into door
	tw.tween_callback(func():
		if _player.has_node("AnimatedSprite2D"):
			_player.get_node("AnimatedSprite2D").play("run")
	).set_delay(0.2)
	tw.tween_property(_player, "global_position:x", global_position.x + 10, 0.5)
	
	# Fade out player
	tw.tween_property(_player, "modulate:a", 0.0, 0.2)
	
	# 9. Fade to black
	tw.tween_property(color_rect, "color:a", 1.0, 1.0)
	
	# 10. Load next cinematic
	tw.tween_callback(_start_coin_toss)

func _open_gate() -> void:
	AudioManager.play("door_open") # Deep thud/open sound
	# Visually shift or hide the gate to show it opening
	sprite.modulate.a = 0.5
	key_sprite.visible = false

func _start_coin_toss() -> void:
	if coin_toss_scene:
		var ct = coin_toss_scene.instantiate()
		get_tree().root.add_child(ct)
		# Pass the player reference if needed, or just let it handle Game Over itself
	
	# Hide the level or just stay black
