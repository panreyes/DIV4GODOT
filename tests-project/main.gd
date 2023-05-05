extends DIVProcess

func init():
	Engine.set_max_fps(60)
	play_music("1",0)

func process():
	await frame(10)
	
	while 1:
		$RichTextLabel.text = str(Engine.get_frames_per_second())
		
		if !exists("bola"):
			DIV.bola(640, 300, 100, 1)
		
		await frame()
