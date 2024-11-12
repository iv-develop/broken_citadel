extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
func hit():
	pass
@export var frozen = false
var hp = 3
func take_damage(_a, _b, _c):
	hp -= 1
	self.velocity = self.velocity.length() * _c +  _b
	if hp <= 1:
		despawn()
@export var speed = 100
func despawn(lt=5):
	for i in range(2):
		var n = GAME.star_bullet.duplicate()
		n.lifetime = lt
		n.vel = Vector2(150, 150).rotated(self.rotation + PI / 2 * i)
		get_parent().add_child(n)
		n.global_position = global_position
	queue_free()
func _physics_process(delta: float) -> void:
	if frozen: return
	else:
		var p = GAME.player
		if p:
			rotate(delta * 2.0)
			velocity = lerp(velocity, (p.global_position - global_position).normalized() * speed, delta)
			move_and_slide()
func smooth_despawn(t=1.0):
	despawn(t)
