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


func _update_buses() -> void:
	var v_bgm := volume_bgm * volume_master
	var v_sfx := volume_sfx * volume_master
	var db_bgm := linear_to_db(v_bgm)
	var db_sfx := linear_to_db(v_sfx)
	AudioServer.set_bus_volume_db(1, db_bgm)
	AudioServer.set_bus_volume_db(2, db_sfx)
