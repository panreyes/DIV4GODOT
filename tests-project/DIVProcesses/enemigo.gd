extends DIVProcess

func init(_x):
	x = _x
	y = -100

func process():
	while y < 800 and action > -1:
		y += 2
		await get_tree().process_frame

