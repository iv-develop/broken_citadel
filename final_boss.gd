extends Node2D




var battle_began = false

func _process(delta: float) -> void:
	if !battle_began: return
	if t > 15:
		var n = GAME.double_bullet.duplicate();
		n.velocity = Vector2(0.0, 0.001)
		n.vel = Vector2(0.0, 0.001)
		n.parryable = true
		n.lifetime = 10
		$SPAWNPOS.add_child(n)
		n.global_position = $SPAWNPOS.global_position
		$Confirm.play()
		t = 0
	else:
		t += delta
	if t1 > 3.:
		for c in [
			$Boss/Side/Cannon,
			$Boss/Side1/Cannon,
			$Boss/Side2/Cannon,
			$Boss/Side3/Cannon
		]:
			if !c.visible: continue
			var dir = Vector2(1.0, 0.0).rotated(randf() * 2 * PI)
			var n = [
				GAME.star_bullet,
				GAME.bullet,
				GAME.double_bullet,
				$RespawnHook.clone
			].pick_random()
			if n:
				var b = n.duplicate()
				b.add_to_group("Projectile")
				b.add_to_group("Despawnable")
				b.velocity = dir * 175
				b.vel = dir * 175
				get_parent().add_child(b)
				b.global_position = c.global_position
		t1 = 0
	else:
		t1 += delta
		
var t1 = 0
var t = 0
var hp = 5
func reset():
	hp = 5
	battle_began = false
	$Boss/Side/Cannon.hide()
	$Boss/Side1/Cannon.hide()
	$Boss/Side2/Cannon.hide()
	$Boss/Side3/Cannon.hide()
	$Boss/Side/CoreShell.show()
	$Boss/Side1/CoreShell.show()
	$Boss/Side2/CoreShell.show()
	$Boss/Side3/CoreShell.show()
	t = 0

func clear_field(t=1.0):
	for node in get_tree().get_nodes_in_group("Projectile"):
		node.smooth_despawn(t)

func _on_hit_body_entered(body: Node2D) -> void:
	if body.is_in_group("Projectile") and body.can_damage_enemies:
		hp -= 1
		$Thunder.play()
		clear_field(0.5)
		match hp:
			4: 
				$Boss/Side/Cannon.show()
				$Boss/Side/CoreShell.hide()
			3:
				$Boss/Side1/Cannon.show()
				$Boss/Side1/CoreShell.hide()
			2:
				$Boss/Side2/Cannon.show()
				$Boss/Side2/CoreShell.hide()
			1:
				$Boss/Side3/Cannon.show()
				$Boss/Side3/CoreShell.hide()
			0:
				battle_began = false
				GAME.player.global_position = $CheckPoint.global_position
				GAME.set_music("SECRET")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if !battle_began:
			$RespawnHook.emitting = true
			print("final battle")
			$EvilLaugh.play()
			battle_began = true
			GAME.set_music("Boss2")
