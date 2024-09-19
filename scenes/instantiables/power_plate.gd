@tool
class_name PowerPlate
extends Node2D


@export var power := Piece.Power.POSSESS
@export var grid_position: Vector2i:
	set(v):
		grid_position = v
		if is_node_ready():
			_update_position()

var _board: Board


func _ready() -> void:
	if get_parent() is not Board:
		printerr("PowerPlate expects parent to be a Board")
		return
	
	_board = get_parent()
	_update_position()


func _exit_tree() -> void:
	_board.unregister_power_plate(self)


func _update_position() -> void:
	if _board == null:
		printerr("PowerPlate not associated with a Board")
		return
	
	position = grid_position * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT)
