extends DIVProcess

var shooting_delay := 0

func process():
	file = "pix"
	animation = "idle" # We are not using graph manually here!
	
	while action > -1:
		await player_playing()
	
	await player_defeated_sequence()

func player_playing():
	# Handle movement
	if shooting_delay <= 0:
		if(key(_left)):
			if !collision("left_wall"): x -= 5
			#graph = 503
			animation = "walk"
			flags = 1
		elif(key(_right)):
			if !collision("right_wall"): x += 5
			#graph = 503
			animation = "walk"
			flags = 0
		else:
			#graph = 501
			animation = "idle"
			flags = 0
		x = clamp(x, 80, 1200)
		
		# Handle bullets
		if(key(_space, on_press)):
			DIV.disparo(x,y)
			animation = "shooting"
			shooting_delay = 6
	else:
		shooting_delay -= 1
	
	if collision("bola"):
		if last_collided_node.x > x: flags = 1
		else: flags = 0
		action = -1
	
	await frame()

func player_defeated_sequence():
	var y_inc
	var x_inc
	
	# If player dies, we pause the game, blink the screen and make the flying player animation
	pausable = 0
	DIVGlobals.game_paused = 1
	animated_sprite.pause()
	
	DIV.white_blink_screen()
	while exists("white_blink_screen"):
		await frame()
	await frame(4)
	animation = "dying"
	
	play_sound("4",0)
	
	y_inc = randi_range(-20,-20)
	
	if flags: x_inc = -10
	else: x_inc = 10
	
	while y < 750:
		y_inc += 0.5
		y += y_inc
		x += x_inc
		if collision("left_wall"): x_inc = abs(x_inc)
		if collision("right_wall"): x_inc = -abs(x_inc)
		
		await frame()
	play_sound("5",0)
