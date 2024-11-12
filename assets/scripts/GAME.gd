extends Node

const IMMORTAL : Color = Color("ff4d00ff");

var enable_opt = true


var saved_pos = Vector2(0, 0)
var saved_speed = 0
var saved_hp = 0
var saved_has_sword = false
var saved_jump_boots = false
var saved_chromo_blade = false
var saved_control_space = false
var saved_hardened_blade = false
var spider_defeated = false
var c_state = []
var deaths = 0

var player = null
var ui = null

@onready var game_root = get_parent().get_node("Game")



var hp = preload("res://assets/scenes/hp.tscn").instantiate()

var double_bullet = preload("res://assets/scenes/double_bullet.tscn").instantiate()
var bullet = preload("res://assets/scenes/bullet_single.tscn").instantiate()
var star_bullet = preload("res://assets/scenes/bouncing_star.tscn").instantiate()

var last_checkpoint_pos = Vector2(0, 0)



var save_path = "user://save_data.json"

func erase_data():
	var config_file := ConfigFile.new()
	config_file.clear()
	var error := config_file.save(save_path)
	if error != OK:
		print("An error happened while loading data: ", error)
		return

const SAVE_VERSION = 3
func try_load_data():
	var config_file := ConfigFile.new()
	var error := config_file.load(save_path)
	if error != OK:
		print("An error happened while loading data: ", error)
		return false
	if len(config_file.get_sections()) == 0:
		print("Empty data!")
		return false
	
	var version = config_file.get_value("save", "version", 0)
	if version != SAVE_VERSION:
		print("Outdated data! Erasing!")
		erase_data()
		return false
	deaths = config_file.get_value("save", "deaths", 0)
	enable_opt = config_file.get_value("save", "enable_opt", true)
	saved_pos = config_file.get_value("save", "saved_pos", Vector2(0, 10))
	saved_speed = config_file.get_value("save", "saved_speed", 100)
	saved_hp = config_file.get_value("save", "saved_hp", 0)
	saved_has_sword = config_file.get_value("save", "saved_has_sword", false)
	saved_jump_boots = config_file.get_value("save", "saved_jump_boots", false)
	saved_chromo_blade = config_file.get_value("save", "saved_chromo_blade", false)
	saved_control_space = config_file.get_value("save", "saved_control_space", false)
	saved_hardened_blade = config_file.get_value("save", "saved_hardened_blade", false)
	spider_defeated = config_file.get_value("save", "spider_defeated", false)
	c_state = config_file.get_value("save", "c_state", [])
	return true

func save_data():
	var config_file := ConfigFile.new()
	config_file.set_value("save", "version", SAVE_VERSION)
	config_file.set_value("save", "deaths", deaths)
	config_file.set_value("save", "enable_opt", enable_opt)
	config_file.set_value("save", "saved_pos", saved_pos)
	config_file.set_value("save", "saved_speed", saved_speed)
	config_file.set_value("save", "saved_hp", saved_hp)
	config_file.set_value("save", "saved_has_sword", saved_has_sword)
	config_file.set_value("save", "saved_jump_boots", saved_jump_boots)
	config_file.set_value("save", "saved_chromo_blade", saved_chromo_blade)
	config_file.set_value("save", "saved_control_space", saved_control_space)
	config_file.set_value("save", "saved_hardened_blade", saved_hardened_blade)
	config_file.set_value("save", "spider_defeated", spider_defeated)
	config_file.set_value("save", "c_state", c_state)
	var error := config_file.save(save_path)
	if error:
		print("An error happened while saving data: ", error)


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

var death_counter = load("res://assets/scenes/death_counter.tscn").instantiate()

func back_to_checkpoint(reset=true):
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
	deaths += 1
	var dc = death_counter.duplicate()
	dc.c = deaths
	game_root.add_child(dc)
	dc.global_position = player.global_position
	#CAMERA.CAMERA_NODE.global_position = saved_pos
	if reset:
		for despawnable in get_tree().get_nodes_in_group("Despawnable"):
			despawnable.queue_free()
		for resetable in get_tree().get_nodes_in_group("Resetable"):
			resetable.reset()
	CAMERA.set_state(c_state)
	set_music(bg_music, 0.5)


func save_checkpoint():
	last_checkpoint_pos = player.global_position
	saved_pos = player.global_position
	saved_speed = player.speed
	saved_has_sword = player.has_sword
	saved_jump_boots = player.jump_boots
	saved_chromo_blade = player.chromo_blade
	saved_control_space = player.control_space
	saved_hardened_blade = player.hardened_blade
	saved_hp = clamp(player.hp, 1, 6)
	c_state = CAMERA.get_state()
	save_data()
func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	player = get_tree().get_nodes_in_group("Player")[0]
	ui = get_parent().get_node("Game/UI")
	saved_speed = player.speed
	saved_pos = player.global_position
	saved_hp = player.hp
	if try_load_data():
		back_to_checkpoint(false)
	
	

func freeze_time(t):
	get_tree().paused = true
	await get_tree().create_timer(t).timeout
	get_tree().paused = false

var settings_opened = false

var music_transition_speed = 1.0
var bg_music = "MusicBG"
var current_music = bg_music
var musics = [
	"MusicBG",
	"MusicLoop",
	"SECRET",
	"Boss0",
	"Boss1",
	"Boss2",
]

func set_music(n, transition_speed=1.0):
	if not musics.has(n):
		print("No such music: ", n)
		return
	current_music = n
	music_transition_speed = transition_speed

var override_db = true

func _process(delta: float) -> void:
	if delta < 0.2: override_db = false
	for m in musics:
		var music_node : AudioStreamPlayer = game_root.get_node("MUSIC").get_node(m)
		if override_db:
			music_node.volume_db = -80.0
			music_node.stop()
			continue
		var s = music_transition_speed
		if s == 0: s = 10.0
		if current_music == m:
			music_node.volume_db = lerp(music_node.volume_db, -25.0, delta * s)
		else:
			music_node.volume_db = lerp(music_node.volume_db, -80.0, delta * s)
		if music_node.volume_db < -75:
			music_node.stop()
		else:
			if !music_node.playing:
				music_node.play()
	if Input.is_action_just_pressed("show_settings"):
		settings_opened = !settings_opened
		if settings_opened:
			ui.show_settings()
		else:
			ui.hide_settings()
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_ALT) and Input.is_action_just_pressed("Reset"):
		print("Save deleted!")
	if Input.is_action_just_pressed("Reset"):
		freeze_time(1.0)
		translate_to_checkpoint()
	ui.get_node("FPS").text = str(Engine.get_frames_per_second())
