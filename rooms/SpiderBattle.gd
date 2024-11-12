extends Node2D

var battle_started = false

enum Attacks {
	SideAttack,
	UpAttack,
	DownAttack,
	Wait
}
var state_time = 0.0
var current_attack = Attacks.Wait;

func _on_trigger_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"): return
	if GAME.spider_defeated: return
	if !battle_started:
		$Awake.play()
		GAME.set_music("Boss0", 2.0)
		battle_started = true
		CAMERA.shake(0.01, 2.0, 0.5)
		time_for_attack = 5.0

var spider_hp = 3
var spawn_delay = 0.6
var spawn_amount = 10
var lifetime = 2
var time_for_attack = 0.0
var waves_spawned = 0

func try_spawn_paryable(dir, waves=4):
	if randf() > 0.85 and waves_spawned > waves:
		var bullet = GAME.bullet.duplicate()
		bullet.parryable = true
		bullet.collision_mask = 1
		bullet.collision_layer = 16 
		bullet.lifetime = 4.0
		bullet.vel = dir * -300.
		$Bullets.add_child(bullet)
		bullet.global_position = $Spider/Head.global_position
var left = false
func _process(delta: float) -> void:
	if !battle_started:
		$Glitch.position.y = move_toward($Glitch.position.y, 0, delta *  800.0)
		return
	if !battle_started: return
	$Glitch.position.y = move_toward($Glitch.position.y, -(3 - spider_hp) * 150, delta * 100.)
	var dir: Vector2 = ($Spider/Head.global_position - GAME.player.global_position).normalized()
	$Spider/Head.rotation = atan2(dir.y, dir.x)
	if state_time <= 0:
		clear_field()
	else:
		state_time -= delta
	time_for_attack -= delta
	if time_for_attack <= 0:
		waves_spawned += 1
		match current_attack:
			Attacks.SideAttack:
				try_spawn_paryable(dir, 9)
				for i in range(spawn_amount / 2):
					var bullet = GAME.bullet.duplicate()
					bullet.parryable = false
					bullet.collision_mask = 0
					bullet.collision_layer = 16
					bullet.lifetime = 16.0 + randf()
					var r = 1
					if left:
						r = -1
					bullet.vel = Vector2(150. * r, 0.)
					$Bullets.add_child(bullet)
					bullet.global_position = Vector2(
						global_position.x - 600 * r + randf() * 10,
						global_position.y - 400 * randf()
					)
					bullet.global_position = round(bullet.global_position / 16) * 16
				time_for_attack = spawn_delay + randf() * 0.5
			Attacks.UpAttack:
				try_spawn_paryable(dir)
				for i in range(spawn_amount * spider_hp - 2):
					var bullet = GAME.bullet.duplicate()
					bullet.parryable = false
					bullet.collision_mask = 0
					bullet.collision_layer = 16
					bullet.lifetime = 5.0 + randf()
					bullet.vel = Vector2(0., 100.)
					$Bullets.add_child(bullet)
					bullet.global_position = Vector2(
						global_position.x + 180 * spider_hp * (randf() * 2.0 - 1.0),
						global_position.y - 400 + (randf() * 2.0 - 1.0) * 10
					)
					bullet.global_position = round(bullet.global_position / 16) * 16
				time_for_attack = spawn_delay + randf() * 0.5
			Attacks.DownAttack:
				try_spawn_paryable(dir)
				for i in range(spawn_amount * spider_hp):
					var bullet = GAME.bullet.duplicate()
					bullet.parryable = false
					bullet.collision_mask = 0
					bullet.collision_layer = 16
					bullet.lifetime = 2.0 + randf()
					bullet.vel = Vector2(0., -100.)
					$Bullets.add_child(bullet)
					bullet.global_position = Vector2(
						global_position.x + 180 * spider_hp * (randf() * 2.0 - 1.0),
						global_position.y + 30 + (randf() * 2.0 - 1.0) * 10
					)
					bullet.global_position = round(bullet.global_position / 16) * 16
				time_for_attack = spawn_delay + randf() * 0.5
			Attacks.Wait:
				current_attack = [Attacks.SideAttack, Attacks.UpAttack, Attacks.DownAttack][randi_range(0, 2)]
				if randf() > 0.5:
					left = false
				else:
					left = true
				state_time = 20.0
				$Spider/AnimationPlayer.play("SKYFALL_TRACK")

func clear_field(t=1.0):
	current_attack = Attacks.Wait
	$Spider/AnimationPlayer.play("RESET")
	for node in get_tree().get_nodes_in_group("Projectile"):
		node.smooth_despawn(t)
	time_for_attack = 2.0
	state_time = 20.0 + time_for_attack
	waves_spawned = 0

func reset():
	spider_hp = 3
	current_attack = Attacks.Wait
	battle_started = false
	time_for_attack = 5.0
	state_time = 2.0 + time_for_attack
	$Glitch.position.y = 0.0
	waves_spawned = 0
	if GAME.spider_defeated:
		$PickUp.show()
		$PickUp.monitorable = true
		$PickUp.monitoring = true
		$Hint.show()
		$Hint.monitorable = true

func _on_hit_body_entered(body: Node2D) -> void:
	if body.is_in_group("Projectile"):
		if body.can_damage_enemies:
			CAMERA.shake(0.01, 5.0, 0.5)
			clear_field(0.4)
			spider_hp -= 1
			$Hurt.play()
			if spider_hp <= 0:
				battle_started = false
				GAME.set_music("MusicBG")
				$PickUp.show()
				$PickUp.monitorable = true
				$PickUp.monitoring = true
				$Hint.show()
				$Hint.monitorable = true
				GAME.save_checkpoint()
				GAME.saved_hp = clamp(GAME.saved_hp, 1, 6)
				GAME.spider_defeated = true
				GAME.saved_jump_boots = true
			
