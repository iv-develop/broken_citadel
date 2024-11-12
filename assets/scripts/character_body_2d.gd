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
const JB_max_time = 0.08
var jumped = false

var hp = 6
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

func play_walk():
	if !$Audio/Walk.playing:
		$Audio/Walk.pitch_scale = randf_range(0.6,  0.7)
		$Audio/Walk.play()

func try_land():
	if state == PlayerState.Fall:
		animation_player.play("Land")
		$Audio/Land.volume_db = -32 + clampf(prev_vel_y * 0.05, 0, 20)
		$Audio/Land.pitch_scale = randf_range(1.4, 1.8) - clampf(prev_vel_y * 0.01, 0.0, 1.0)
		$Audio/Land.play(0)
		if abs(prev_vel_y) > 300:
			$FallParticles.amount = 8
			if abs(prev_vel_y) > 400:
				$FallParticles.amount = 16
			if abs(prev_vel_y) > 550:
				$FallParticles.amount = 32
			$FallParticles.emitting = true

func slide(delta):
	prev_vel_y = velocity.y
	prev_vel_x = velocity.x
	move_and_slide()
	CAMERA.update(delta)

var sword_delay = 0.3
var c_sword_delay = 0.0

var sequence_progression = 0
var attack_buffer = 0.0
var attack_buffer_max = 0.08
const actions = [
	"ui_up",
	"ui_down",
	"ui_left",
	"ui_right",
	"A",
	"B"
]

func other_pressed():
	for action in actions:
		if Input.is_action_just_pressed(action): return true
	return false

func _physics_process(delta: float) -> void:
	match sequence_progression:
		0: if Input.is_action_just_pressed("ui_up"): sequence_progression += 1
		elif other_pressed(): sequence_progression = 0
		1: if Input.is_action_just_pressed("ui_up"): sequence_progression += 1
		elif other_pressed(): sequence_progression = 0
		2: if Input.is_action_just_pressed("ui_down"): sequence_progression += 1
		elif other_pressed(): sequence_progression = 0
		3: if Input.is_action_just_pressed("ui_down"): sequence_progression += 1
		elif other_pressed(): sequence_progression = 0
		4: if Input.is_action_just_pressed("ui_left"): sequence_progression += 1
		elif other_pressed(): sequence_progression = 0
		5: if Input.is_action_just_pressed("ui_right"): sequence_progression += 1
		elif other_pressed(): sequence_progression = 0
		6: if Input.is_action_just_pressed("ui_left"): sequence_progression += 1
		elif other_pressed(): sequence_progression = 0
		7: if Input.is_action_just_pressed("ui_right"): sequence_progression += 1
		elif other_pressed(): sequence_progression = 0
		8: if Input.is_action_just_pressed("B"): sequence_progression += 1
		elif other_pressed(): sequence_progression = 0
		9: if Input.is_action_just_pressed("A"): sequence_progression += 1
		elif other_pressed(): sequence_progression = 0
		10:
			sequence_progression = 0
			GAME.set_music("SECRET")
			GAME.bg_music = "SECRET"
	
	
	var left = Input.is_action_pressed("Left")
	var right = Input.is_action_pressed("Right")
	var up = Input.is_action_pressed("Up")
	var down = Input.is_action_pressed("Down")
	var attack = Input.is_action_just_pressed("Attack")
	var direction := int(right) - int(left)
	var omnidirection = Vector2(direction, int(down) - int(up)).normalized()
	attack_buffer -= delta
	if has_sword:
		var mouse_pos = get_global_mouse_position()
		var dir = (mouse_pos - global_position).normalized()
		if !$Rapier/RapierAnimations.is_playing():
			$Rapier.rotation = atan2(dir.y, dir.x)
		c_sword_delay += delta
		if c_sword_delay >= sword_delay and (attack or (attack_buffer > 0)):
			if attack and !$Rapier/RapierAnimations.is_playing():
				attack_buffer = attack_buffer_max
			c_sword_delay = 0.0
			$Rapier/RapierAnimations.play("Slash")
			var bodies = $Rapier.get_overlapping_bodies()
			var areas = $Rapier.get_overlapping_areas()
			var bounce_bodies = $Rapier/RapierBounce.get_overlapping_bodies()
			var any_collided = false
			for area in areas:
				if area.is_in_group("Damagable"):
					area.take_damage(global_position, velocity, dir)
					any_collided = true
				if area.is_in_group("Stream") and chromo_blade:
					area.activate()
					any_collided = true
			for body in bodies:
				if body.is_in_group("Damagable"):
					body.take_damage(global_position, velocity, dir)
					any_collided = true
				if body.is_in_group("RapierLight"):
					velocity = JUMP_VELOCITY * 0.75 * dir
					any_collided = true
				if not is_on_floor():
					if hardened_blade and body.is_in_group("RapierHeavy"):
						velocity = JUMP_VELOCITY * 0.75 * dir
						any_collided = true
			for body in bounce_bodies:
				if not is_on_floor():
					velocity = JUMP_VELOCITY * 1.2 * dir
					any_collided = true
			if any_collided:
				GAME.freeze_time(0.05)
				$Rapier/Audio/Parry.pitch_scale = randf_range(1.2, 1.6)
				$Rapier/Audio/Parry.play(0)
			else:
				$Rapier/Audio/Swing.pitch_scale = randf_range(1.05, 1.4)
				$Rapier/Audio/Swing.play(0)
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
		elif velocity == Vector2(0, 0):
			velocity.y = move_toward(velocity.y, get_gravity().y, velocity_buffer_air_gain)
		if !is_on_floor():
			if velocity.y == 0 and velocity.x == 0:
				if velocity.y == 0:
					velocity.y = -prev_vel_y
				if velocity.x == 0:
					velocity.x = -prev_vel_x
			slide(delta)
			state = PlayerState.Fall
			animation_player.play("Fall")
			return
	var jump_pressed := Input.is_action_just_pressed("ui_accept");
	var jumping := Input.is_action_pressed("ui_accept");
	if is_on_floor():
		jump_buffer = 0.0
		velocity.x = move_toward(velocity.x, direction * speed, velocity_buffer_gain)
		if direction:
			play_walk()
		air_jumps = MAX_AIR_JUMPS
		jumped = false
		if jump_pressed:
			jumped = true
			$Audio/Jump.pitch_scale = randf_range(0.5, 0.8)
			$Audio/Jump.play(0)
			velocity.y = JUMP_VELOCITY
		try_land()
		state = PlayerState.Idle
	elif jump_pressed and jump_buffer < JB_max_time and not jumped:
		velocity.y = JUMP_VELOCITY
		$Audio/Jump.pitch_scale = randf_range(0.5, 0.8)
		$Audio/Jump.play(0)
		jumped = true
	elif jump_boots and jump_pressed and air_jumps > 0:
		$Audio/Jump.pitch_scale = randf_range(1.5, 2.0)
		$Audio/Jump.play(0)
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
	
	slide(delta)
	jump_buffer += delta
func heal(amount):
	hp += amount
	hp = clamp(hp, 0, 6)
	GAME.ui.set_health(hp)
	$Audio/HpUp.play()
	update_sat()
func take_damage(amount):
	$Audio/Hurt.pitch_scale = randf_range(0.7, 1.4)
	$Audio/Hurt.play()
	if $HitAnimations.is_playing(): return
	hp -= amount
	update_sat()
	if hp <= 2:
		$Audio/LowHp.play()
	if hp <= 0:
		GAME.translate_to_checkpoint()
		$HitAnimations.play("Death")
		
	else:
		$HitAnimations.play("Hit")
		GAME.freeze_time(0.05)
	GAME.ui.set_health(hp)
func update_sat():
	$"../ENV".environment.adjustment_saturation = 0.2 + clamp(hp, 0, 6) * 0.8 / 6
func revive():
	$HitAnimations.play("RESET")
	$HitBox.monitoring = true
	update_sat()

func _on_hit_box_area_entered(area: Area2D) -> void:
	node_entered(area)

func _on_hit_box_body_entered(body: Node2D) -> void:
	node_entered(body)

func node_entered(node: Node2D):
	if node.is_in_group("DoubleDamage"):
		take_damage(2)
	else:
		if node.is_in_group("Projectile"):
			node.hit()
		take_damage(1)
