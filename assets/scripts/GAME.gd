extends Node

const IMMORTAL : Color = Color("ff4d00ff");

var saved_pos = Vector2(0, 0)
var saved_speed = 0
var saved_hp = 0
var saved_has_sword = false
var saved_jump_boots = false
var saved_chromo_blade = false
var saved_control_space = false
var saved_hardened_blade = false

var spider_defeated = false

var saved_cam_rects = []
var saved_cam_zoom = Vector2(1.0, 1.0)
var saved_cam_node_zoom = Vector2(1.0, 1.0)
var saved_cam_ov_zoom : float
var saved_cam_pos = Vector2(0.0, 0.0)
var c_state = []
var player = null
var ui = null

@onready var game_root = get_parent().get_node("Game")

var hp = preload("res://assets/scenes/hp.tscn").instantiate()

var double_bullet = preload("res://assets/scenes/double_bullet.tscn").instantiate()
var bullet = preload("res://assets/scenes/bullet_single.tscn").instantiate()
var star_bullet = preload("res://assets/scenes/bouncing_star.tscn").instantiate()

var last_checkpoint_pos = Vector2(0, 0)

func begin_play_music():
	pass


func try_spawn_hp(pos: Vector2, p: float = 0.5):
	if randf() >= p:
		var g = get_parent().get_node("Game")
		var n = hp.duplicate()
		g.add_child(n)
		n.global_position = pos


func checkpoint_transition_hook():
	back_to_checkpoint()

func translate_to_checkpoint(t=0.5):
	ui.get_node("Respawn").play()
	ui.get_node("AnimationPlayer").play("InOut")
	GAME.freeze_time(t)
func back_to_checkpoint():
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
	player.revive()
	#CAMERA.CAMERA_NODE.global_position = saved_pos
	for despawnable in get_tree().get_nodes_in_group("Despawnable"):
		despawnable.queue_free()
	for resetable in get_tree().get_nodes_in_group("Resetable"):
		resetable.reset()
	#CAMERA.room_bound_rects = saved_cam_rects
	#CAMERA.CAMERA_NODE.global_position = saved_cam_pos
	#CAMERA.CAMERA_NODE.zoom = saved_cam_node_zoom
	#CAMERA.perfer_zoom = saved_cam_zoom
	#CAMERA.override_zoom = saved_cam_ov_zoom
	#CAMERA.update(0.1)
	CAMERA.set_state(c_state)
	
	
func save_checkpoint():
	last_checkpoint_pos = player.global_position
	saved_pos = player.global_position
	saved_speed = player.speed
	saved_has_sword = player.has_sword
	saved_jump_boots = player.jump_boots
	saved_chromo_blade = player.chromo_blade
	saved_control_space = player.control_space
	saved_hardened_blade = player.hardened_blade
	saved_hp = player.hp
	#saved_cam_rects = CAMERA.room_bound_rects
	#saved_cam_zoom = CAMERA.perfer_zoom
	#saved_cam_ov_zoom = CAMERA.override_zoom
	#saved_cam_pos = CAMERA.CAMERA_NODE.global_position
	#saved_cam_node_zoom = CAMERA.CAMERA_NODE.zoom
	c_state = CAMERA.get_state()
	

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
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
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_ALT) and Input.is_action_just_pressed("Reset"):
		print("Save deleted!")
	d += delta
	if d > 0.1:
		d -= 0.1
		frame = (frame + 1) % 3
		Input.set_custom_mouse_cursor(frames[frame])
	if Input.is_action_just_pressed("Reset"):
		freeze_time(1.0)
		translate_to_checkpoint()
	get_parent().get_node("Game/DBG/Label").text = str(Engine.get_frames_per_second())
