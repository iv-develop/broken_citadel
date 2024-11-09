extends CharacterBody2D


const SPEED = 180.0
const JUMP_VELOCITY = -300.0
const JUMP_GRAV = 0.6

@onready var player_sprite = $PlayerSprite
@onready var animation_player = $SpriteAnimations

enum PlayerState {
	Idle,
	Run,
	Jump,
	Fall,
}

var state = PlayerState.Idle

var jump_buffer := 0.0
const JB_max_time = 0.05
var jumped = false


var velocity_buffer = 0.0
var velocity_buffer_gain = 20.0
var velocity_buffer_air_gain = velocity_buffer_gain / 2.


# abilities
var control_space = true

var max_air_jumps : int = 1
var air_jumps : int = max_air_jumps

var rapier_groundjump = true


func _process(delta):
	if $Rapier/RapierAnimations.is_playing(): return
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	$Rapier.rotation = atan2(direction.y, direction.x)

func _physics_process(delta: float) -> void:
	var left = Input.is_action_pressed("Left")
	var right = Input.is_action_pressed("Right")
	var up = Input.is_action_pressed("Up")
	var down = Input.is_action_pressed("Down")
	var attack = Input.is_action_just_pressed("Attack")
	var direction := int(right) - int(left)
	var omnidirection = Vector2(direction, int(down) - int(up)).normalized()
	if attack:
		$Rapier/RapierAnimations.play("Slash")
		$Rapier.monitoring = true
		var bodies = $Rapier.get_overlapping_bodies()
		if not is_on_floor():
			for body in bodies:
				if rapier_groundjump and body.is_in_group("RapierHeavy"):
					var mouse_pos = get_global_mouse_position()
					var dir = (mouse_pos - global_position).normalized()
					velocity = JUMP_VELOCITY * 0.75 * dir
					velocity_buffer = velocity.x
	if $NoGrav.has_overlapping_bodies():
		if direction:
			if direction < 0:
				player_sprite.flip_h = true
			else:
				player_sprite.flip_h = false
		if control_space:
			if omnidirection:
				velocity.x = move_toward(velocity.x, omnidirection.x * SPEED, velocity_buffer_air_gain)
				velocity.y = move_toward(velocity.y, omnidirection.y * SPEED, velocity_buffer_air_gain)
				velocity_buffer = velocity.x
		else:
			velocity_buffer = velocity.x
		move_and_slide()
		state = PlayerState.Fall
		animation_player.play("Fall")
		CAMERA.update(delta)
		return
	
	var jump_pressed := Input.is_action_just_pressed("ui_accept");
	var jumping := Input.is_action_pressed("ui_accept");
	if is_on_floor():
		jump_buffer = 0.0
		velocity_buffer = move_toward(velocity_buffer, direction * SPEED, velocity_buffer_gain)
		air_jumps = max_air_jumps
		jumped = false
		if jump_pressed:
			jumped = true
			velocity.y = JUMP_VELOCITY
		if state == PlayerState.Fall:
			animation_player.play("Land")
		state = PlayerState.Idle
	elif jump_pressed and jump_buffer < JB_max_time and not jumped:
		velocity.y = JUMP_VELOCITY
		jumped = true
	elif jump_pressed and air_jumps > 0:
		velocity.y = JUMP_VELOCITY * 0.8
		air_jumps -=1
	else:
		if direction:
			velocity_buffer = move_toward(velocity_buffer, direction * SPEED, velocity_buffer_air_gain)
		if state == PlayerState.Jump and jumping:
			velocity += get_gravity() * delta * JUMP_GRAV
		else:
			velocity += get_gravity() * delta
		if velocity.y < 0:
			state = PlayerState.Jump
		else:
			state = PlayerState.Fall
	
	velocity.x = velocity_buffer
	if state == PlayerState.Idle and (velocity_buffer or left or right):
		state = PlayerState.Run
	
	if animation_player.current_animation != "Land":
		if state == PlayerState.Idle:
			animation_player.play("Idle")
		if state == PlayerState.Run:
			animation_player.play("Run")
	if state == PlayerState.Jump:
		animation_player.play("Jump")
	if state == PlayerState.Fall:
		animation_player.play("Fall")
	
	if direction:
		if direction < 0:
			player_sprite.flip_h = true
		else:
			player_sprite.flip_h = false
	
	move_and_slide()
	$State.text = "State: " + PlayerState.keys()[state]
	CAMERA.update(delta)
	jump_buffer += delta
	return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y < 0:
			state = PlayerState.Jump
		else:
			state = PlayerState.Fall
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if is_on_floor():
		if state == PlayerState.Fall:
			animation_player.play("Land")
		state = PlayerState.Idle
	
	if direction:
		if direction < 0:
			player_sprite.flip_h = true
		else:
			player_sprite.flip_h = false
		if is_on_floor():
			velocity.x = direction * SPEED
			state = PlayerState.Run
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
	if animation_player.current_animation != "Land":
		if state == PlayerState.Idle:
			animation_player.play("Idle")
		if state == PlayerState.Run:
			animation_player.play("StartRun")
	if state == PlayerState.Jump:
		animation_player.play("Jump")
	if state == PlayerState.Fall:
		animation_player.play("Fall")
	move_and_slide()
	$State.text = "State: " + PlayerState.keys()[state]
	CAMERA.update(delta)
