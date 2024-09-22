class_name TurnManager
extends Node


var _controllers: Array[Controller] = []
var _turn_idx := -1


func _ready() -> void:
	if get_parent() is World:
		get_parent().register_turn_manager(self)
		_controllers = get_parent().get_controllers().duplicate()
		#_controllers.sort_custom(_sort_controller)
		
		for c in _controllers:
			c.turn_passed.connect(next_turn)


func _sort_controller(a: Controller, b: Controller) -> bool:
	return a.get_team() < b.get_team()


func next_turn() -> void:
	if _controllers.is_empty():
		return
	
	var all_controller_available_move_counts := 0
	for controller in _controllers:
		all_controller_available_move_counts += controller.get_available_move_count()
	
	if all_controller_available_move_counts == 0:
		Hud.game_over(Hud.GameOver.DRAW)
		return
	
	var prev: Controller
	if _turn_idx >= 0:
		prev = _controllers[_turn_idx]
		prev.end_turn()
	
	_turn_idx = wrapi(_turn_idx + 1, 0, len(_controllers))
	
	var next := _controllers[_turn_idx]
	if next.get_available_move_count() == 0:
		next_turn.call_deferred()
		return
	next.begin_turn()
	
	var available_move_count := next.get_available_move_count()
	var prev_move_count := prev.get_move_count() if prev != null else 0
	if next.get_team() != Piece.Team.NEUTRAL:
		Hud.report_turn(next.get_team(), prev_move_count > 0 and available_move_count > 0)
