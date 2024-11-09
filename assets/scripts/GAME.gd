extends Node

var saved_pos = Vector2(0, 0)
var saved_speed = 0
var saved_has_sword = false
var saved_jump_boots = false
var saved_chromo_blade = false
var saved_control_space = false
var saved_hardened_blade = false
var player = null

func back_to_checkpoint():
	player.global_position = saved_pos
	player.speed = saved_speed
	player.has_sword = saved_has_sword
	player.jump_boots = saved_jump_boots
	player.chromo_blade = saved_chromo_blade
	player.control_space = saved_control_space
	player.hardened_blade = saved_hardened_blade
	for despawnable in get_tree().get_nodes_in_group("Despawnable"):
		despawnable.queue_free()
	for resetable in get_tree().get_nodes_in_group("Resetable"):
		resetable.reset()

func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player")[0]
	saved_speed = player.speed
	saved_pos = player.global_position
func _process(d: float) -> void:
	if Input.is_action_just_pressed("Reset"):
		back_to_checkpoint()
	get_parent().get_node("Game/DBG/Label").text = str(Engine.get_frames_per_second())
