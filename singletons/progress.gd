extends Node


var play_count := 0
var last_level := -1


func _enter_tree() -> void:
	load_from_file()


func save_to_file() -> void:
	var dir := DirAccess.open("user://")
	
	var json := JSON.stringify({
		&"play_count": play_count,
		&"last_level": last_level,
	})
	
	var file := FileAccess.open("user://progress.json", FileAccess.WRITE)
	file.store_string(json)
	
	print("SAVED PROGRESS TO FILE '%s'" % file.get_path_absolute())


func load_from_file() -> void:
	var dir := DirAccess.open("user://")
	if not dir.file_exists("progress.json"):
		printerr("Could not load progress: no progress file found. If this is your first time playing the game, or you are starting a new game, this is expected behaviour; please ignore this message if so.")
		return
	
	var file := FileAccess.open("user://progress.json", FileAccess.READ)
	var contents := file.get_as_text()
	var json = JSON.parse_string(contents)
	
	if json == null or json is not Dictionary:
		printerr("Something went wrong when trying to parse data for progress file '%s'. File contents: %s" % [file.get_path_absolute(), contents])
		return
	
	play_count = json.play_count
	last_level = json.last_level
	
	print("LOADED PROGRESS FROM FILE '%s'" % file.get_path_absolute())


func delete_progress_file() -> void:
	var dir := DirAccess.open("user://")
	if not dir.file_exists("progress.json"):
		printerr("Could not delete progress: no progress file found.")
		return
	
	dir.remove("progress.json")
