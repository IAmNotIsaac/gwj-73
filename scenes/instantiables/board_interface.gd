@tool
class_name BoardInterface
extends Node


const _TIME_COMPREHENSION := 1.0

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
var _world: World
var _camera_controller: CameraController

@onready var _parabola := $ParabolaLine2D
@onready var _line_back := $LineBack
@onready var _line_active := $LineActive
@onready var _land := $InterfaceLand
@onready var _stars_begin := $StarsBegin
@onready var _stars_end := $StarsEnd


func _ready() -> void:
	if get_parent() is not Board:
		printerr("BoardInterface expects parent to be a Board")
		return
	
	if get_tree().current_scene is World:
		_world = get_tree().current_scene
		_camera_controller = _world.get_camera_controller()
	
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
	_stars_begin.position = from
	_stars_end.position = from


func unlock() -> void:
	if _unlocked:
		return
	_unlocked = true
	
	_stars_begin.emitting = true
	var initial_camera_pos = _camera_controller.get_position()
	_camera_controller.set_position(_parabola.position)
	_camera_controller.set_free(false)
	_world.begin_cutscene()
	await get_tree().create_timer(_TIME_COMPREHENSION).timeout
	_stars_end.emitting = true
	for p in _parabola._line.points:
		_camera_controller.set_position(_parabola.position + p)
		_line_back.add_point(p)
		_line_active.add_point(p)
		_stars_end.position = p + _parabola.position
		await get_tree().create_timer(0.01).timeout
	await get_tree().create_timer(_TIME_COMPREHENSION).timeout
	_camera_controller.set_position(initial_camera_pos)
	_camera_controller.set_free(true)
	_world.end_cutscene()


func is_locked() -> bool:
	return not _unlocked
