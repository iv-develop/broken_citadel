extends CharacterBody2D


func take_damage(_g, _v, _d):
	if hardened: return
	self.hp -= 1
	if self.hp <= 0:
		GAME.try_spawn_hp(global_position)
		queue_free()
		


func _ready() -> void:
	if hardened:
		$Sprite2D.modulate = GAME.IMMORTAL

@export var hp = 2
@export var hardened = false
@export var current_direction = Vector2(-150, 0)
func _physics_process(delta: float) -> void:
	# step forward
	var step = move_and_collide(current_direction * delta, true)
	if step:
		# step up
		self.position += delta * current_direction
		current_direction = current_direction.rotated(PI / 2)
	else:
	 	# step bottom
		var btm = current_direction.rotated(-PI / 2)
		var res = move_and_collide(btm * delta)
		if !res:
			current_direction = btm
