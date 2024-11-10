@tool
extends Area2D
@onready var particles = $CPUParticles2D
@onready var sprite = $Sprite2D
@export var powerup_id = 0
var picked = false
func _ready() -> void:
	sprite.frame = powerup_id

func reset():
	picked = false
	particles.show()
	sprite.show()
	particles.emitting = true

func _on_body_entered(player: Node2D) -> void:
	if picked: return
	if !player.is_in_group("Player"): return
	$Picked.play(0)
	match powerup_id:
		0: player.has_sword = true
		1: player.speed = player.BOOTS_SPEED
		2: player.jump_boots = true
		3: player.chromo_blade = true
		4: player.control_space = true
		5: player.hardened_blade = true
	particles.emitting = false
	picked = true
	particles.hide()
	sprite.hide()
