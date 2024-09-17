class_name TurnManager
extends Node


var _controllers: Array[Controller] = []
var _turn_idx := -1


func _ready() -> void:
	if get_parent() is World:
		_controllers = get_parent().get_controllers().duplicate()
		_controllers.sort_custom(_sort_controller)
		
		for c in _controllers:
			c.turn_passed.connect(next_turn)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		next_turn()


func _sort_controller(a: Controller, b: Controller) -> bool:
	return a.get_team() < b.get_team()


func next_turn() -> void:
	if _controllers.is_empty():
		return
	
	if _turn_idx > 0:
		var prev := _controllers[_turn_idx]
		prev.end_turn()
	
	_turn_idx = wrapi(_turn_idx + 1, 0, len(_controllers))
	
	var next := _controllers[_turn_idx]
	next.begin_turn()
	
	print("TURN: %s" % next)
