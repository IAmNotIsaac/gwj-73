class_name Controller
extends Node


signal turn_complete

@export var pieces: Array[Piece]:
	set=set_pieces


func _enter_tree() -> void:
	for p in pieces:
		print(p.board)


func _set_pieces(value: Array[Piece]) -> void:
	pieces = value


func _get_team() -> Piece.Team:
	return Piece.Team.NEUTRAL


func _turn_begun() -> void:
	pass


func set_pieces(value: Array[Piece]) -> void:
	_set_pieces(value)


func get_team() -> Piece.Team:
	return _get_team()


func begin_turn() -> void:
	_turn_begun()
