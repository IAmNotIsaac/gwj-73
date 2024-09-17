class_name World
extends Node2D


var _boards: Array[Board] = []


func register_board(board: Board) -> void:
	if board in _boards:
		printerr("Tried to double-register board (%s)" % board)
		return
	_boards.push_back(board)


func get_boards() -> Array[Board]:
	return _boards
