class_name EventController
extends Controller


var _world: World
var _events: Array[Event] = []


func _ready() -> void:
	if not get_parent() is World:
		printerr("World is not the parent of event controller %s, could not safely load events." % self)
		return
	
	_world = get_parent()
	
	for c in get_children():
		if c is Event:
			_register_event(c)


func _turn_begun() -> void:
	for event in _events:
		await event.fire()
	turn_passed.emit()


func _register_event(event: Event) -> void:
	if event in _events:
		printerr("Tried to double-register event (%s)" % event)
		return
	
	_events.push_back(event)
	
	event.world = _world
	event.controller = self
