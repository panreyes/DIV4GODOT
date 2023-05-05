extends DIVProcess

func process():
	var id_col
	var shooting_delay := 0
	
	file = "pix"
	animation = "idle" # We are not using graph manually here!
	
	# FIXME This should not go here, but good enough for now
	DIVAssets.add_animation(file, "idle", 0.4, 501, 501)
	DIVAssets.add_animation(file, "walk", 0.4, 502, 505)
	DIVAssets.add_animation(file, "shooting", 0.4, 506, 506)
	
	while action > -1:
		# Handle movement
		if shooting_delay <= 0:
			if(key(_left)):
				x -= 5
				#graph = 503
				animation = "walk"
				flags = 1
			elif(key(_right)):
				x += 5
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
		
		# Handle collision agains enemy
		id_col = collision("enemigo")
		if id_col:
			action = -1
		
		await frame()

	# Disappear after being defeated
	while alpha > 0:
		alpha -= 5
		angle += 3000
		size -= 3
		await frame()

