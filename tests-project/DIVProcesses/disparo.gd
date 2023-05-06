extends DIVProcess

func init(_x, _y):
	x = _x
	y = _y
	z = -100

func process():
	play_sound("1",0)
	
	file = "pix"
	animation = "weapon1"
	
	while y > -100 and action > -1:
		y -= 5
		
		if(collision("ceiling")):
			break
		await frame()
