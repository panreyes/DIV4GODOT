extends Node2D

var scene_paths = {}

func _init():
	preload_divprocesses()

func preload_divprocesses():
	var folder_path = "res://DIVProcesses/"
	var dir_access = DirAccess.open(folder_path)
	dir_access.list_dir_begin()

	while true:
		var file_path = dir_access.get_next()
		if file_path == "":
			break
		if file_path.get_extension() == "tscn":
			add_divprocess(folder_path + file_path)

	dir_access.list_dir_end()

func add_divprocess(scene_path):
	var process_type = scene_path.get_file().get_basename()
	if scene_paths.has(process_type):
		return
	scene_paths[process_type] = scene_path
	load(scene_path) # For caching purposes

func instance(process_type, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null):
	if !scene_paths.has(process_type):
		print("Error: Can't instance " + process_type)
		return null
	
	var pid = load(scene_paths[process_type]).instantiate()
	pid.set_args([arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9])
	get_tree().get_root().add_child(pid)
