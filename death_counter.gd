extends Node2D


var c = 0
func _enter_tree() -> void:
	var t = create_tween()
	$Label.text = "Смертей - " + str(c) 
	t.tween_property($Label, "position", Vector2(0.0, -70.0), 1.0).set_ease(Tween.EASE_OUT)
	t.tween_property($Label, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(2.5).timeout
	self.queue_free()
