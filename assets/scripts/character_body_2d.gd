extends CharacterBody2D


const SPEED = 180.0
const JUMP_VELOCITY = -300.0

@onready var player_sprite = $PlayerSprite
@onready var animation_player = $SpriteAnimations

enum PlayerState {
	Idle,
	Run,
	Jump,
	Fall,
}

var state = PlayerState.Idle
var prev_on_floor = false
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y < 0:
			state = PlayerState.Jump
		else:
			state = PlayerState.Fall
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if is_on_floor():
		if state == PlayerState.Fall:
			animation_player.play("Land")
		state = PlayerState.Idle
	if direction:
		velocity.x = direction * SPEED
		if is_on_floor():
			state = PlayerState.Run
		if direction < 0:
			player_sprite.flip_h = true
		else:
			player_sprite.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if animation_player.current_animation != "Land":
		if state == PlayerState.Idle:
			animation_player.play("Idle")
		if state == PlayerState.Run:
			animation_player.play("Run")
	if state == PlayerState.Jump:
		animation_player.play("Jump")
	if state == PlayerState.Fall:
		animation_player.play("Fall")
	move_and_slide()
	$State.text = "State: " + PlayerState.keys()[state]
	CAMERA.update(delta)
	prev_on_floor = is_on_floor()
