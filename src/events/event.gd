class_name Event
extends Node


@export var fire_once := false
@export var delegate_only := false

var world: World
var controller: EventController
var _fire_count := 0


func _fire() -> void:
	pass


func fire() -> void:
	if delegate_only:
		return
	
	if fire_once and _fire_count > 0:
		return
	
	@warning_ignore("redundant_await")
	await _fire()
	
	_fire_count += 1


func delegate() -> void:
	if fire_once and _fire_count > 0:
		return
	
	@warning_ignore("redundant_await")
	await _fire()
	
	_fire_count += 1
