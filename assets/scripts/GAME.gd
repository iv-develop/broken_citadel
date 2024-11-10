extends Node

var saved_pos = Vector2(0, 0)
var saved_speed = 0
var saved_hp = 0
var saved_has_sword = false
var saved_jump_boots = false
var saved_chromo_blade = false
var saved_control_space = false
var saved_hardened_blade = false
var saved_cam_state = []
var player = null
var ui = null

func checkpoint_transition_hook():
	back_to_checkpoint()

func translate_to_checkpoint():
	ui.get_node("Respawn").play()
	ui.get_node("AnimationPlayer").play("InOut")

func back_to_checkpoint():
	player.revive()
	player.global_position = saved_pos
	player.speed = saved_speed
	player.velocity = Vector2(0, 0)
	player.has_sword = saved_has_sword
	player.jump_boots = saved_jump_boots
	player.chromo_blade = saved_chromo_blade
	player.control_space = saved_control_space
	player.hardened_blade = saved_hardened_blade
	player.hp = saved_hp
	ui.set_health(saved_hp)
	#CAMERA.CAMERA_NODE.global_position = saved_pos
	for despawnable in get_tree().get_nodes_in_group("Despawnable"):
		despawnable.queue_free()
	for resetable in get_tree().get_nodes_in_group("Resetable"):
		resetable.reset()
	CAMERA.room_bound_rects = saved_cam_state
	var s = CAMERA.follow_speed
	CAMERA.follow_speed = 0.0
	CAMERA.update(0.01)
	CAMERA.follow_speed = s
	
func save_checkpoint():
	saved_pos = player.global_position
	saved_speed = player.speed
	saved_has_sword = player.has_sword
	saved_jump_boots = player.jump_boots
	saved_chromo_blade = player.chromo_blade
	saved_control_space = player.control_space
	saved_hardened_blade = player.hardened_blade
	saved_cam_state = CAMERA.room_bound_rects
	saved_hp = player.hp

func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player")[0]
	ui = get_parent().get_node("Game/UI")
	saved_speed = player.speed
	saved_pos = player.global_position
	saved_hp = player.hp

func freeze_time(t):
	get_tree().paused = true
	await get_tree().create_timer(t).timeout
	get_tree().paused = false

var d = 0.0
var frame = 0
var frames = [load("res://assets/images/cursor1.png"), load("res://assets/images/cursor2.png"), load("res://assets/images/cursor3.png")]
func _process(delta: float) -> void:
	d += delta
	if d > 0.1:
		d -= 0.1
		frame = (frame + 1) % 3
		Input.set_custom_mouse_cursor(frames[frame])
	if Input.is_action_just_pressed("Reset"):
		translate_to_checkpoint()
	get_parent().get_node("Game/DBG/Label").text = str(Engine.get_frames_per_second())
