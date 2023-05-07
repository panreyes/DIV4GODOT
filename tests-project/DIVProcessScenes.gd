extends Node2D

var scene_paths = {}

func _init():
	preload_divprocesses()

func preload_divprocesses():
	var cache_needs_update = false
	var folder_path = "res://DIVProcesses/"
	var dir_access = DirAccess.open(folder_path)
	var file_path
	var process_type
	
	dir_access.list_dir_begin()
	
	if DIV == null:
		cache_needs_update = true
	
	while true:
		file_path = dir_access.get_next()
		process_type = file_path.get_basename()
		if file_path == "":
			break
		if file_path.get_extension() == "tscn":
			add_divprocess(folder_path + file_path)
			if !cache_needs_update:
				if !DIV.has_method(process_type):
					print("Method does not exist ", process_type)
					cache_needs_update = true

	dir_access.list_dir_end()
	
	if cache_needs_update:
		generate_cache_file()

func add_divprocess(scene_path):
	var process_type = scene_path.get_file().get_basename()
	if scene_paths.has(process_type):
		return
	scene_paths[process_type] = scene_path
	load(scene_path) # For caching purposes
	
func generate_cache_file():
	var source_code
	var process_type
	
	source_code = "extends Node2D

func _ready():
	pass
"
	
	for scene in scene_paths:
		process_type = scene.get_file().get_basename()
		source_code += "
func " + process_type + "(arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null):
	return DIVProcessScenes.instance(\"" + process_type +  "\", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)	
"
	var file := FileAccess.open("res://DIVProcesses/DIV.gd", FileAccess.WRITE)
	file.store_string(source_code)
	
	print("Regenerated DIV.gd, launch again!")

func instance(process_type, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null):
	if !scene_paths.has(process_type):
		print("Error: Can't instance " + process_type)
		return null
	
	var node = load(scene_paths[process_type]).instantiate()
	node.set_args([arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9])
	get_tree().get_root().add_child(node)
	return node
