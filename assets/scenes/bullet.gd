extends CharacterBody2D

func _ready() -> void:
	if !parryable:
		$Sprite2D.modulate = GAME.IMMORTAL
	await get_tree().create_timer(lifetime).timeout
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

@export var vel = Vector2(-100, 0)
@export var parryable = true
@export var lifetime = 5.0

var can_damage_enemies = false

func smooth_despawn(t=1.0):
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
	await get_tree().create_timer(t).timeout
	queue_free()

func take_damage(gp, _v, dir):
	if vel == Vector2(0.0, 0.0):
		vel = dir * 100
	else:
		vel = clamp(vel.length(), 100, 1000) * dir
	self.collision_layer = 16 + 32 + 128
	can_damage_enemies = true

func hit():
	self.queue_free()


func _physics_process(delta: float) -> void:
	var res = move_and_collide(vel * delta)
	if res:
		queue_free()
