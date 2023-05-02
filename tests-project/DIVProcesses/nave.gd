extends DIVProcess

func process():
	var id_col
	
	while action > -1:
		# Handle movement
		if(key(_left)):
			x -= 5
		if(key(_right)):
			x += 5
		x = clamp(x, 80, 1200)
		
		# Handle bullets
		if(key(_space, on_press)):
			# Find out a way to just use disparo(x,y)
			DIVProcessScenes.instance("disparo", x, y)
		
		# Handle collision agains enemy
		id_col = collision("enemigo")
		if id_col:
			action = -1
		
		#frame()
		await get_tree().process_frame

	# Disappear after being defeated
	while alpha > 0:
		alpha -= 5
		angle += 3000
		size -= 3
		#frame()
		await get_tree().process_frame

