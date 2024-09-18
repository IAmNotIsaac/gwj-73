@tool
extends Node


@export var grid_position: Vector2i:
	set(v):
		grid_position = v
		_update_parabola()
@export_subgroup("to_")
@export var to_board: Board:
	set(v):
		to_board = v
		_update_parabola()
@export var to_grid_position: Vector2i:
	set(v):
		to_grid_position = v
		_update_parabola()

var _unlocked := false

@onready var _parabola := $ParabolaLine2D
@onready var _line_back := $LineBack
@onready var _line_active := $LineActive
@onready var _land := $InterfaceLand


func _ready() -> void:
	_update_parabola()


func _enter_tree() -> void:
	_update_parabola()


func _update_parabola() -> void:
	if not is_node_ready():
		await ready
	
	if get_parent() is not Board:
		printerr("BoardInterface expects parent to be a Board")
		return
	
	var ts := Vector2(Board.TILE_WIDTH, Board.TILE_HEIGHT)
	var from: Vector2 = get_parent().position + Vector2(grid_position) * ts + ts * 0.5
	var to: Vector2 = to_board.position + Vector2(to_grid_position) * ts + ts * 0.5
	to -= from
	
	_parabola.position = from
	_parabola.target_position = to
	_line_back.position = from
	_line_active.position = from
	_land.position = from + to


func unlock() -> void:
	if _unlocked:
		return
	_unlocked = true
	
	for p in _parabola._line.points:
		_line_back.add_point(p)
		_line_active.add_point(p)
		await get_tree().create_timer(0.005).timeout
