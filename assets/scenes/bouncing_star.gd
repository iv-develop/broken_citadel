extends CharacterBody2D


var vel = Vector2(100, 30)

func _enter_tree() -> void:
	if !parryable:
		$Sprite2D.modulate = GAME.IMMORTAL
	await get_tree().create_timer(5).timeout
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 0), 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 0), 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 0), 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 0), 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 0), 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_BOUNCE)
	await get_tree().create_timer(1).timeout
	queue_free()

func smooth_despawn(t=1.0): pass

func _physics_process(delta: float) -> void:
	vel += get_gravity() * 0.5 * delta
	var res = move_and_collide(vel * delta)
	if res:
		var new_vel = vel.bounce(res.get_normal())
		if new_vel.y < 0.0 and vel.y > 0.0:
			new_vel.y = 200. * sign(new_vel.y);
		vel = new_vel
	else:
		vel.x = move_toward(vel.x, 100 * sign(vel.x), delta)
@export var parryable = true
func hit():
	pass

func take_damage(gp, _v, dir):
	vel = vel.length() * dir
	self.collision_layer = 16 + 32
