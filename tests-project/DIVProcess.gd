extends Sprite2D

class_name DIVProcess

@export var process_type = ""
@export var instance_name = ""
@export var id := 0

# FIXME: Mirar cómo resolver ésto!
@export var action : int = 0
@export var file = ""
@export var graph = 0
@export var x : float = 0.0;
@export var y : float = 0.0;
@export var z : int = 0;
@export var alpha : float = 255.0;
@export var size : float = 100.0;
@export var size_x : float = 100.0;
@export var size_y : float = 100.0;
@export var angle : float = 0.0;
@export var flags : int = 0
@export var animation := ""

# Private local variables
var _file_previous = ""
var _graph_previous = 0
var _animation_previous = ""

#var args := {}
# Ugly, but necessary. No variadic functions!
var args

const _left = "ui_left"
const _right = "ui_right"
const _up = "ui_up"
const _down = "ui_down"
const _space = "_key_space"

enum { on_press = 1, on_release = 2 }

#onready var sprite = Sprite2D.new()
@onready var sprite = self
@onready var area = Area2D.new()
var animated_sprite

var node_iterator: int = 0
var node_iterator_last_type := ""

# I wish I could define this macro, or make it a function
#define Frame(); await get_tree().idle_frame

func _ready():
	fetch_properties_from_node()
	fetch_div_locals_from_node() #DIV locals properties have priority over node properties
	if(has_method("init")):
		var parms = args
		
		for method in get_script().get_script_method_list():
			if method.name == "init":
				if len(method.args) > 0:
					for i in range(9, len(method.args), -1):
						parms.pop_back()
				else:
					parms = {}
		
		if len(parms) == 0:
			await call("init")
		else:
			await callv("init",parms)
	
	update_godot_values_from_div_values()
	
	if process_type == "":
		process_type = get_scene_file_path().get_file().get_basename()
		if process_type == "":
			process_type = get_name()
		else:
			DIVProcessScenes.add_divprocess(get_scene_file_path())
	
	instance_name = get_name()
	id = get_instance_id()
	
	add_child(area)
	#add_child(sprite)
	setup_collider()
	
	add_to_group("DIVProcess")
	add_to_group(process_type)
	
	if(has_method("process")):
		await call("process")
		queue_free()
	else:
		while action > -1:
			await get_tree().process_frame

func set_args(_args):
	args = _args

func fetch_div_locals_from_node():
	# Only update them if they're set from the editor
	if action == null: action = 0
	if x == null: x = 0.0
	if y == null: y = 0.0
	if z == null: z = 0
	if alpha == null: alpha = 255.0
	if size == null: size = 100.0
	if size_x == null: size_x = 100.0
	if size_y == null: size_y = 100.0
	if angle == null: angle = 0.0

func fetch_properties_from_node():
	x = position.x
	y = position.y
	z = z_index
	alpha = modulate.a * 255
	angle = rotation * 360000
	size = scale.x * 100
	if (scale.x == scale.y):
		size_x = 100
		size_y = 100
	else:
		size_x = scale.x * 100
		size_y = scale.y * 100

func collision(target_process_type):
	for body in area.get_overlapping_areas():
		var node = body.get_parent()
		if (node.process_type):
			if node.process_type == target_process_type:
				return node
	
	return null

func setup_collider():	
	# If there's a CollisionPolygon2D or CollisionXXXXX, use it
	for child in get_children():
		if child is CollisionPolygon2D:
			remove_child(child)
			area.add_child(child)
			return
	
	if(!sprite.texture):
		print("Could not generate collider, it has no sprite. Process type ", process_type)
		return
	
	var bm = BitMap.new()
	bm.create_from_image_alpha(sprite.texture.get_image())

	var rect = Rect2(Vector2.ZERO, sprite.texture.get_size())
	var my_array = bm.opaque_to_polygons(rect)
	if my_array.is_empty():
		print("Could not generate collider, could not generate polygon. Process type ", process_type)
		return
	
	var polygon2D = Polygon2D.new()
	polygon2D.set_polygons(my_array)
	var col_polygon = CollisionPolygon2D.new()
	col_polygon.set_polygon(polygon2D.polygons[0])
	
	# Shape centered
	col_polygon.position -= (sprite.texture.get_size() / 2)
	area.add_child(col_polygon)

func set_fps(fps_target, _skip):
	Engine.set_max_fps(fps_target)
	
func frame(frames = 1):
	if not get_tree():
		await get_tree().createtimer(0.1).timeout
		return
	while frames > 0:
		frames -= 1
		await get_tree().process_frame

func update_godot_values_from_div_values():
	node_iterator = 0
	node_iterator_last_type = ""
	position = Vector2(x, y)
	modulate.a = alpha / 255
	rotation = angle / 360000
	z_index = z
	if (size_x == 100 and size_y == 100):
		scale.x = size / 100
		scale.y = size / 100
	else:
		scale.x = size_x / 100
		scale.y = size_y / 100
	if scale.x < 0 or scale.y < 0:
		scale.x = 0
		scale.y = 0
	
	if flags == 1 or flags == 3:
		scale.x = -scale.x
	
	if flags == 2 or flags == 3:
		scale.y = -scale.y

func _process(_delta):
	if !animated_sprite:
		update_graph()
	update_animation()
	update_godot_values_from_div_values()

func update_animation():
	if animation != _animation_previous:
		_animation_previous = animation
		
		if !animated_sprite:
			#sprite.visible = 0
			sprite.texture = null
			animated_sprite = AnimatedSprite2D.new()
			add_child(animated_sprite)
			sprite = animated_sprite #testing
		
		animated_sprite.set_sprite_frames(DIVAssets.get_animation(file))
		animated_sprite.play(animation)

func key(key_name, event = 0):
	if event == 0:
		return Input.is_action_pressed(key_name)
	elif(event == on_press):
		return Input.is_action_just_pressed(key_name)
	elif(event == on_release):
		return Input.is_action_just_released(key_name)

func process_fade_off(speed):
	for i in range(alpha, 0, speed):
		alpha = i
		angle += 3000
		size -= 3
		#frame()
		await get_tree().process_frame

func exists(type):
	var nodes = get_tree().get_nodes_in_group(type)
	
	for node in nodes:
		if node.action >= 0:
			return true
	
	return false


func get_id(type):
	var nodes = get_tree().get_nodes_in_group(type)
	
	var iterations := 0
	if node_iterator_last_type != type:
		node_iterator = 0
		node_iterator_last_type = type
	
	node_iterator += 1
	
	for node in nodes:
		if node.action >= 0:
			iterations += 1
			if iterations == node_iterator:
				return node

func play_music(music, repeats):
	DIVAssets.play_music(music, repeats)

func play_sound(sound, repeats):
	DIVAssets.play_sound(sound, repeats)

func update_graph():
	var changed := false
	if _file_previous != file:
		_file_previous = file
		changed = true
	if _graph_previous != graph:
		_graph_previous = graph
		changed = true
	
	if changed:
		texture = DIVAssets.get_graph_texture(file, str(graph))
