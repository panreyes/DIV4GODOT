extends Node2D

var fpgs = {}
var musics = {}
var sounds = {}
var animations = {}
@onready var music_player = AudioStreamPlayer.new()

func _init():
	preload_fpgs()
	preload_musics()
	preload_sounds()

func _ready():
	add_child(music_player)

func preload_musics():
	for file in DirAccess.get_files_at("res://DIV/music/"):
		if file.get_extension() == "ogg":
			load_music(file)

func load_music(file):
	musics[file.get_basename()] = load("res://DIV/music/" + file)

func preload_sounds():
	for file in DirAccess.get_files_at("res://DIV/sound/"):
		if file.get_extension() == "wav":
			load_sound(file)

func load_sound(file):
	sounds[file.get_basename()] = load("res://DIV/sound/" + file)

func preload_fpgs():
	for dir in DirAccess.get_directories_at("res://DIV/fpg"):
		load_fpg(dir)

func load_fpg(dir):
	var fpg = {}
	for file in DirAccess.get_files_at("res://DIV/fpg/" + dir):
		if file.get_extension() == "png":
			fpg[file.get_basename()] = load("res://DIV/fpg/" + dir + "/" + file)
	
	fpgs[dir] = fpg

func get_graph_texture(file, graph):
	if fpgs.has(file):
		if fpgs[file].has(graph):
			return fpgs[file][graph]
	
	return null

func play_music(music, repeats):
	if !musics.has(music):
		music_player.stop()
		return null
	
	music_player.stream = musics[music]
	
	if repeats == -1: repeats = 9999
	
	if repeats > 0:
		musics[music].loop = true
		musics[music].loop_count = repeats
	else:
		musics[music].loop = false
	music_player.play()

func play_sound(sound, repeats):
	var sound_player = AudioStreamPlayer.new()
	sound_player.stream = sounds[sound]
# does not have any sense :|
#	if repeats > 0:
#		sounds[sound].loop = true
#		sounds[sound].loop_count = repeats
#	else:
#		sounds[sound].loop = false
	add_child(sound_player)
	sound_player.play()

func get_animation(file):
	if animations.has(file):
		return animations[file]
	
	return null

func add_animation(file, animation_name, frame_delay, first_frame, last_frame = 999):
	var _sprite_frames
	if animations.has(file):
		_sprite_frames = animations[file]
		if _sprite_frames.has_animation(animation_name):
			return false
	else:
		_sprite_frames = SpriteFrames.new()
	
	_sprite_frames.add_animation(animation_name)
	
	# Stupidly stupid: range does not work if both numbers are the same.
	# Stupid workaround
	for i in range(first_frame,999):
		if fpgs[file].has(str(i)):
			_sprite_frames.add_frame(animation_name, get_graph_texture(file,str(i)), frame_delay)
		else:
			break
		if i == last_frame:
			break
	
	animations[file] = _sprite_frames
	
	return true
	#animated_sprite.frame_delay = frame_delay
