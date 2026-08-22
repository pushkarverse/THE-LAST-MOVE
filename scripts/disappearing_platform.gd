extends StaticBody2D

@onready var sprite := $Sprite2D
@onready var shape := $CollisionShape2D
@onready var detect_area := $Area2D

var _active: bool = true

func _ready() -> void:
	detect_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _active and body.has_method("die"): # player check
		_active = false
		# Shake effect
		var tween = create_tween()
		for i in range(5):
			tween.tween_property(sprite, "position", Vector2(2, 0), 0.05)
			tween.tween_property(sprite, "position", Vector2(-2, 0), 0.05)
		tween.tween_property(sprite, "position", Vector2(0, 0), 0.05)
		tween.tween_callback(_disappear)

func _disappear() -> void:
	hide()
	shape.set_deferred("disabled", true)
	await get_tree().create_timer(2.0).timeout
	show()
	shape.set_deferred("disabled", false)
	_active = true
