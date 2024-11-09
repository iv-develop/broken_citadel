extends CharacterBody2D


const SPEED = 120.0
const BOOTS_SPEED = 180.0
const JUMP_VELOCITY = -280.0
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


var velocity_buffer_gain = 20.0
var velocity_buffer_air_gain = velocity_buffer_gain / 2.


const MAX_AIR_JUMPS : int = 1
var air_jumps : int = 1

# abilities
var speed = SPEED
var has_sword = false
var jump_boots = false
var chromo_blade = false
var control_space = false
var hardened_blade = false

var prev_vel_y = 0
var prev_vel_x = 0

func _physics_process(delta: float) -> void:
	var left = Input.is_action_pressed("Left")
	var right = Input.is_action_pressed("Right")
	var up = Input.is_action_pressed("Up")
	var down = Input.is_action_pressed("Down")
	var attack = Input.is_action_just_pressed("Attack")
	var direction := int(right) - int(left)
	var omnidirection = Vector2(direction, int(down) - int(up)).normalized()
	if has_sword:
		if !$Rapier/RapierAnimations.is_playing():
				var mouse_pos = get_global_mouse_position()
				var dir = (mouse_pos - global_position).normalized()
				$Rapier.rotation = atan2(dir.y, dir.x)
		if attack:
			$Rapier/RapierAnimations.play("Slash")
			var bodies = $Rapier.get_overlapping_bodies()
			var areas = $Rapier.get_overlapping_areas()
			var bounce_bodies = $Rapier/RapierBounce.get_overlapping_bodies()
			for body in bounce_bodies:
				if not is_on_floor():
					var mouse_pos = get_global_mouse_position()
					var dir = (mouse_pos - global_position).normalized()
					velocity = JUMP_VELOCITY * 1.2 * dir
			for area in areas:
				if area.is_in_group("Stream") and chromo_blade:
					area.activate()
			for body in bodies:
				if body.is_in_group("Damagable"):
					body.take_damage(global_position, velocity)
				if body.is_in_group("RapierLight"):
					var mouse_pos = get_global_mouse_position()
					var dir = (mouse_pos - global_position).normalized()
					velocity = JUMP_VELOCITY * 0.75 * dir
				if not is_on_floor():
					if hardened_blade and body.is_in_group("RapierHeavy"):
						var mouse_pos = get_global_mouse_position()
						var dir = (mouse_pos - global_position).normalized()
						velocity = JUMP_VELOCITY * 0.75 * dir
	if $NoGrav.has_overlapping_bodies():
		if direction:
			if direction < 0:
				player_sprite.flip_h = true
			else:
				player_sprite.flip_h = false
		if control_space:
			if omnidirection:
				velocity.x = move_toward(velocity.x, omnidirection.x * speed, velocity_buffer_air_gain)
				velocity.y = move_toward(velocity.y, omnidirection.y * speed, velocity_buffer_air_gain)
		if !is_on_floor():
			if velocity.y == 0 and velocity.x == 0:
				if velocity.y == 0:
					velocity.y = -prev_vel_y
				if velocity.x == 0:
					velocity.x = -prev_vel_x
			prev_vel_y = velocity.y
			prev_vel_x = velocity.x
			move_and_slide()
			state = PlayerState.Fall
			animation_player.play("Fall")
			CAMERA.update(delta)
			return
	var jump_pressed := Input.is_action_just_pressed("ui_accept");
	var jumping := Input.is_action_pressed("ui_accept");
	if is_on_floor():
		jump_buffer = 0.0
		velocity.x = move_toward(velocity.x, direction * speed, velocity_buffer_gain)
		air_jumps = MAX_AIR_JUMPS
		jumped = false
		if jump_pressed:
			jumped = true
			velocity.y = JUMP_VELOCITY
		if state == PlayerState.Fall and abs(prev_vel_y) > 1:
			animation_player.play("Land")
		state = PlayerState.Idle
	elif jump_pressed and jump_buffer < JB_max_time and not jumped:
		velocity.y = JUMP_VELOCITY
		jumped = true
	elif jump_boots and jump_pressed and air_jumps > 0:
		velocity.y = JUMP_VELOCITY * 0.8
		air_jumps -=1
	else:
		if direction:
			velocity.x = move_toward(velocity.x, direction * speed, velocity_buffer_air_gain)
		if state == PlayerState.Jump and jumping:
			velocity += get_gravity() * delta * JUMP_GRAV
		else:
			velocity += get_gravity() * delta
		if velocity.y < 0:
			state = PlayerState.Jump
		else:
			state = PlayerState.Fall
	
	if state == PlayerState.Idle and (velocity.x or left or right):
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
	
	prev_vel_y = velocity.y
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
			velocity.x = direction * speed
			state = PlayerState.Run
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, speed)
	if animation_player.current_animation != "Land":
		if state == PlayerState.Idle:
			animation_player.play("Idle")
		if state == PlayerState.Run:
			animation_player.play("StartRun")
	if state == PlayerState.Jump:
		animation_player.play("Jump")
	if state == PlayerState.Fall:
		animation_player.play("Fall")
	prev_vel_y = velocity.y
	prev_vel_x = velocity.x
	move_and_slide()
	$State.text = "State: " + PlayerState.keys()[state]
	CAMERA.update(delta)


func _on_hit_box_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_hit_box_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
