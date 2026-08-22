extends Area2D

var _triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _triggered: return
	if body.has_method("reached_exit_door"):
		_triggered = true
		body.reached_exit_door()
	elif body.has_user_signal("reached_exit"):
		_triggered = true
		body.emit_signal("reached_exit")
