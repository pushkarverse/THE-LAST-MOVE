extends Label

func _ready() -> void:
	var tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var base_y = position.y
	tw.tween_property(self, "position:y", base_y - 4.0, 1.2)
	tw.tween_property(self, "position:y", base_y, 1.2)
