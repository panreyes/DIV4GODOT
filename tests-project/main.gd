extends DIVProcess

func init():
	Engine.set_max_fps(60)
	prepare_animations()
	start_game()

func start_game():
	play_music("1",0)

func process():
	# Wait a few frames until the tree is ready
	await frame(10)
	
	while 1:
		$fps_text.text = str(Engine.get_frames_per_second())
		
		if !exists("ball"):
			DIV.ball(640, 300, 100, 1)
		
		await frame()

func prepare_animations():
	#fpg pix
	DIVAssets.add_animation("pix", "idle", 0.4, 501, 501)
	DIVAssets.add_animation("pix", "walk", 0.4, 502, 505)
	DIVAssets.add_animation("pix", "shooting", 0.4, 506, 506)
	
	DIVAssets.add_animation("pix", "weapon1", 0.2, 601, 602)
	DIVAssets.add_animation("pix", "dying", 0.2, 508, 508)
