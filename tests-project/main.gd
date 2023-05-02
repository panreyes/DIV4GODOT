extends Node2D

func _ready():
	Engine.set_max_fps(60)
	#pass
	
func _process(_delta):
	$RichTextLabel.text = str(Engine.get_frames_per_second())
	
	if randi() % 51 == 50:
		DIVProcessScenes.instance("enemigo", randi() % 1281)
