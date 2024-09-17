class_name Controller
extends Node


signal turn_complete


func _get_team() -> Piece.Team:
	return Piece.Team.NEUTRAL


func _turn_begun() -> void:
	pass


func get_team() -> Piece.Team:
	return _get_team()


func begin_turn() -> void:
	_turn_begun()
