extends DIVProcess

func init(_x, _y):
	x = _x
	y = _y

func process():
	var id_col
	while y > -100 and action > -1:
		y -= 5
		id_col = collision("enemigo")
		if(id_col):
			id_col.action = -1
			break
		await frame()
