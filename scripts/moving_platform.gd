extends AnimatableBody2D

@export var offset_target: Vector2 = Vector2(100, 0)
@export var duration: float = 2.0

var _start_pos: Vector2

func _ready() -> void:
	_start_pos = position
	_start_tween()

func _start_tween() -> void:
	var tween := create_tween().set_loops().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", _start_pos + offset_target, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", _start_pos, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
