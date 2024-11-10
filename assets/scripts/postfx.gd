extends CanvasLayer


func checkpoint_transition_hook():
	GAME.back_to_checkpoint()

	#if event is InputEventKey:
		#if event.pressed:
			#if event.keycode == KEY_0: set_health(0)
			#if event.keycode == KEY_1: set_health(1)
			#if event.keycode == KEY_2: set_health(2)
			#if event.keycode == KEY_3: set_health(3)
			#if event.keycode == KEY_4: set_health(4)
			#if event.keycode == KEY_5: set_health(5)
			#if event.keycode == KEY_6: set_health(6)



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
