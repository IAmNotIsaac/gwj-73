class_name EventDelegate
extends Event


@export var event: Event
@export var share_world := true
@export var share_controller := true

var permission := false


func _fire() -> void:
	if permission:
		if share_world:
			event.world = world
		if share_controller:
			event.controller = controller
		event.delegate()


func handle(signal_: Signal) -> void:
	var default_handle := func():
		permission = true
	signal_.connect(default_handle)
