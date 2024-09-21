class_name Controller
extends Node


signal turn_passed

var turn := 0


func _enter_tree() -> void:
	if get_parent() is World:
		get_parent().register_controller(self)


func _get_team() -> Piece.Team:
	return Piece.Team.NEUTRAL


func _get_move_count() -> int:
	return 0


func _get_available_move_count() -> int:
	return 0


func _turn_begun() -> void:
	pass


func _turn_ended() -> void:
	pass


func get_team() -> Piece.Team:
	return _get_team()


func get_move_count() -> int:
	return _get_move_count()


func get_available_move_count() -> int:
	return _get_available_move_count()


func begin_turn() -> void:
	_turn_begun()
	turn += 1


func end_turn() -> void:
	_turn_ended()
