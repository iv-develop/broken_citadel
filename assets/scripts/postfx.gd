extends CanvasLayer


func checkpoint_transition_hook():
	GAME.back_to_checkpoint()

var master_bus_idx = AudioServer.get_bus_index("Master")
var sword_bus_idx = AudioServer.get_bus_index("Sword")
var player_music_bus_idx = AudioServer.get_bus_index("Player")
var fx_music_bus_idx = AudioServer.get_bus_index("FX")
var music_bus_idx = AudioServer.get_bus_index("Music")
var enemies_bus_idx = AudioServer.get_bus_index("Enemy")

func set_health(amount):
	for node in get_node("HealthContainer").get_children():
		var i = node.name.to_int() + 1
		var sprite = node.get_node("Sprite")
		if i * 2 - 1 == amount:
			sprite.frame = 1
		elif i * 2 <= amount:
			sprite.frame = 0
		else:
			sprite.frame = 2

func show_settings():
	$SETTINGS.show()

func hide_settings():
	$SETTINGS.hide()

func _on_music_s_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(music_bus_idx, value < 0.05)

func _on_fxs_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(fx_music_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(fx_music_bus_idx, value < 0.05)

func _on_player_s_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(player_music_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(player_music_bus_idx, value < 0.05)

func _on_sword_s_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sword_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(sword_bus_idx, value < 0.05)

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus_idx, value < 0.05)

func _on_enemies_s_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(enemies_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(enemies_bus_idx, value < 0.05)

func _on_delete_save_pressed() -> void:
	GAME.erase_data()

func _ready() -> void:
	$SETTINGS/CenterContainer/GridContainer/VSyncOP.selected = DisplayServer.window_get_vsync_mode()

func _on_v_sync_op_item_selected(index: int) -> void:
	DisplayServer.window_set_vsync_mode(index) 

func _on_option_button_item_selected(index: int) -> void:
	$FPS.visible = index
