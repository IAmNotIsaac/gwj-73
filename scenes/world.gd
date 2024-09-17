class_name World
extends Node2D


var boards: Array[Board] = []


func register_board(board: Board) -> void:
	boards.push_back(board)
