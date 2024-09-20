extends Node


var volume_master := 1.0:
	set(v):
		volume_master = v
		_update_buses()
var volume_bgm := 1.0:
	set(v):
		volume_bgm = v
		_update_buses()
var volume_sfx := 1.0:
	set(v):
		volume_sfx = v
		_update_buses()
var camera_speed := 500.0
var camera_pan_factor := 25.0


func _enter_tree() -> void:
	_update_buses()
	load_from_file()


func _update_buses() -> void:
	var v_bgm := volume_bgm * volume_master
	var v_sfx := volume_sfx * volume_master
	var db_bgm := linear_to_db(v_bgm)
	var db_sfx := linear_to_db(v_sfx)
	AudioServer.set_bus_volume_db(1, db_bgm)
	AudioServer.set_bus_volume_db(2, db_sfx)


func save_to_file() -> void:
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("settings"):
		dir.make_dir("settings")
	
	var event_move_up := InputMap.action_get_events(&"move_up")[0]
	var event_move_down := InputMap.action_get_events(&"move_down")[0]
	var event_move_left := InputMap.action_get_events(&"move_left")[0]
	var event_move_right := InputMap.action_get_events(&"move_right")[0]
	
	ResourceSaver.save(event_move_up, "user://settings/event_move_up.tres")
	ResourceSaver.save(event_move_down, "user://settings/event_move_down.tres")
	ResourceSaver.save(event_move_left, "user://settings/event_move_left.tres")
	ResourceSaver.save(event_move_right, "user://settings/event_move_right.tres")
	
	var json := JSON.stringify({
		&"volume_master": volume_master,
		&"volume_bgm": volume_bgm,
		&"volume_sfx": volume_sfx,
		&"camera_speed": camera_speed,
		&"camera_pan_factor": camera_pan_factor,
	})
	
	var file := FileAccess.open("user://settings/settings.json", FileAccess.WRITE)
	file.store_string(json)
	
	print("SAVED SETTINGS TO FILE '%s'" % file.get_path_absolute())


func load_from_file() -> void:
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("settings"):
		printerr("Could not load settings; no settings directory found. If this is your first time loading the game, this is expected behaviour and ignore this message.")
		return
	
	var file := FileAccess.open("user://settings/settings.json", FileAccess.READ)
	var contents := file.get_as_text()
	var json = JSON.parse_string(contents)
	
	if json == null or json is not Dictionary:
		printerr("Something went wrong when trying to parse data for settings file '%s'" % file.get_path_absolute())
		return
	
	volume_master = json.volume_master
	volume_bgm = json.volume_bgm
	volume_sfx = json.volume_sfx
	camera_speed = json.camera_speed
	camera_pan_factor = json.camera_pan_factor
	
	InputMap.action_erase_events(&"move_up")
	InputMap.action_erase_events(&"move_down")
	InputMap.action_erase_events(&"move_left")
	InputMap.action_erase_events(&"move_right")
	
	InputMap.action_add_event(&"move_up", load("user://settings/event_move_up.tres"))
	InputMap.action_add_event(&"move_down", load("user://settings/event_move_down.tres"))
	InputMap.action_add_event(&"move_left", load("user://settings/event_move_left.tres"))
	InputMap.action_add_event(&"move_right", load("user://settings/event_move_right.tres"))
	
	print("LOADED SETTINGS FROM FILE '%s'" % file.get_path_absolute())
