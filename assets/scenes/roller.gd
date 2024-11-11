extends CharacterBody2D


@export var speed = 50;
@export var hardened = false
var hp = 0
func _ready() -> void:
	if hardened:
		$Roller.modulate = GAME.IMMORTAL

func _physics_process(delta: float) -> void:
	velocity.x = speed
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	move_and_slide()
	if is_on_wall():
		speed = -speed


func take_damage(_a, _b, _c):
	if hardened: return
	hp -= 1
	if hp <= 0:
		GAME.try_spawn_hp(global_position)
		queue_free()
