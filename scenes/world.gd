class_name World
extends Node2D


var _boards: Array[Board] = []
var _controllers: Array[Controller] = []


func register_board(board: Board) -> void:
	if board in _boards:
		printerr("Tried to double-register board (%s)" % board)
		return
	_boards.push_back(board)


func register_controller(controller: Controller) -> void:
	if controller in _controllers:
		printerr("Tried to double-register controller (%s)" % controller)
		return
	_controllers.push_back(controller)


func get_boards() -> Array[Board]:
	return _boards


func get_controllers() -> Array[Controller]:
	return _controllers
