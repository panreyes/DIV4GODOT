extends DIVProcess

const gravity := 0.2
var x_inc := 2.5
var y_inc := -3.0
var direction := 1
var minimum_bounce := 6.5

func init(_x,_y,_size, _direction):
	x = _x
	y = _y
	size = _size
	direction = _direction

func process():
	var id_col
	
	while action > -1:	
		if collision("ground"):
			y_inc = -absf(y_inc)
			y_inc = min(y_inc, -minimum_bounce)
			# FIXME:
			#print(y_inc)
		
		id_col = collision("wall")
		if id_col:
			if id_col.x < x:
				direction = -1
			else:
				direction = 1
		
		id_col = collision("disparo")
		if id_col:
			id_col.action = -1
			play_sound("2",0)
			if size > 20:
				DIV.bola(x-10, y, size - 20, -1)
				DIV.bola(x+10, y, size - 20, 1)
			break
		
		y_inc += gravity
		y += y_inc
		x += direction * x_inc
		
		await frame()
