extends Node2D

var fpgs = {}
var musics = {}
var sounds = {}
var animations = {}
const force_use_filelist = false
@onready var music_player = AudioStreamPlayer.new()

func _init():
	preload_fpgs()
	preload_musics()
	preload_sounds()
	#load_assets("res://DIV/music/","ogg","load_music")

func _ready():
	add_child(music_player)

func generate_file_list_json(path, extension):
	var file_list = {}
	var i = 0
	
	for file in DirAccess.get_files_at(path):
		if file.get_extension() == extension:
			i += 1
			file_list[i] = file
	
	var fp = FileAccess.open(path + "/filelist.dat", FileAccess.WRITE)
	fp.store_var(file_list)
	fp.close()
	
	return file_list
	
func generate_dir_list_json(path):
	var dir_list = {}
	var i = 0
	for dir in DirAccess.get_directories_at(path):
		i += 1
		dir_list[i] = dir
	
	var fp = FileAccess.open(path + "/dirlist.dat", FileAccess.WRITE)
	fp.store_var(dir_list)
	fp.close()
	
	return dir_list

func load_assets(path,extension,callback_load_function_name):
	var file_list
	
	if OS.has_feature("editor") and !force_use_filelist:
		file_list = generate_file_list_json(path, extension)
	else:
		var fp = FileAccess.open(path + "/filelist.dat", FileAccess.READ)
		file_list = fp.get_var()
	
	if file_list == null:
		return
	
	for file in file_list.values():
		call(callback_load_function_name, path + "/" + file)
		#print(file)

func preload_musics():
	load_assets("res://DIV/music","ogg","load_music")

func load_music(file):
	musics[file.get_file().get_basename()] = load(file)

func preload_sounds():
	load_assets("res://DIV/sound","wav","load_sound")

func load_sound(file):
	sounds[file.get_file().get_basename()] = load(file)

func preload_fpgs():
	var dir_list
	
	if OS.has_feature("editor") and !force_use_filelist:
		dir_list = generate_dir_list_json("res://DIV/fpg")
	else:
		var fp = FileAccess.open("res://DIV/fpg/dirlist.dat", FileAccess.READ)
		dir_list = fp.get_var()
	
	for dir in dir_list.values():
		load_fpg("res://DIV/fpg/" + dir)

func load_fpg(dir):
	var fpg = {}
	var file_list
	
	if OS.has_feature("editor") and !force_use_filelist:
		file_list = generate_file_list_json(dir, "png")
	else:
		var fp = FileAccess.open(dir + "/filelist.dat", FileAccess.READ)
		file_list = fp.get_var()
	
	for file in file_list.values():
		fpg[file.get_file().get_basename()] = load(dir + "/" + file)
	
	fpgs[dir.get_file()] = fpg

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
