extends Area2D

func _ready() -> void:
	var r = RectangleShape2D.new()
	r.size = $LabelCopy.size
	$CollisionShape2D.shape = r


var hp = 3

func reset():
	hp = 3
	$LabelCopy.show()
	monitorable = true

func take_damage(_p, _v, d) -> void:
	var c = -$LabelCopy.size * 0.5
	hp -= 1
	if hp <= 0:
		$LabelCopy.hide()
		monitorable = false
	var tween = create_tween()
	tween.tween_property($LabelCopy, "position", c + Vector2(d * 12), 0.1).set_ease(Tween.EASE_OUT);
	tween.tween_property($LabelCopy, "position", c + Vector2(0.0, 0.0), 0.2).set_ease(Tween.EASE_IN_OUT);

func _process(delta: float) -> void:
	pass
