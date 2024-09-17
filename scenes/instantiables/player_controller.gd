class_name PlayerController
extends Controller


const _CAMERA_SPEED := 500.0
const _PAN_FACTOR := 25.0
const _ICON_MOVE := preload("res://assets/textures/icon_move.svg")
const _ICON_STRIKE := preload("res://assets/textures/icon_strike.svg")
const _ICON_POSSESS := preload("res://assets/textures/icon_possess.svg")
const _ZOOM_DEFAULT := 1.0
const _ZOOM_SELECTED := 1.1

var _handled_pieces: Array[Piece] = []
var _click_func = _handle_click_root
var _camera_position := Vector2.ZERO
var _camera_zoom := _ZOOM_DEFAULT
var _camera_free := true

@export var camera: Camera2D


func _ready() -> void:
	_camera_position = camera.position
	
	if get_parent() is World:
		for board in get_parent().boards:
			board.tile_clicked.connect(_on_tile_clicked.bind(board))


func _process(delta: float) -> void:
	if camera != null:
		var d := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down") * int(_camera_free)
		_camera_position += d * delta * _CAMERA_SPEED
		var mp := get_viewport().get_mouse_position() / get_viewport().get_visible_rect().size
		mp = mp.clamp(Vector2.ZERO, Vector2.ONE)
		mp = (mp - Vector2(0.5, 0.5)) * 2.0;
		var pan := mp * _PAN_FACTOR
		camera.position = _camera_position + pan
		camera.zoom = camera.zoom.lerp(Vector2.ONE * _camera_zoom, 0.25)


func _get_team() -> Piece.Team:
	return Piece.Team.BLACK


func _camera_settings(position: Vector2, zoom: float, free: bool) -> void:
	_camera_position = position
	_camera_zoom = zoom
	_camera_free = free


func _on_tile_clicked(button_index: MouseButton, grid_position: Vector2i, board: Board) -> void:
	_click_func.call(button_index, grid_position, board)


func _handle_click_root(button_index: MouseButton, grid_position: Vector2i, board: Board) -> void:
	var selected_piece: Piece = board.get_piece(grid_position)
	if selected_piece == null:
		return
	if selected_piece.team != get_team():
		return
	if selected_piece in _handled_pieces:
		return
	
	var movable_positions := selected_piece.get_movable_positions()
	var strikeable_positions := selected_piece.get_strikeable_positions()
	var icons: Array[Sprite2D] = []
	_click_func = _handle_click_move.bind(selected_piece, movable_positions, strikeable_positions, icons)
	
	selected_piece.mark_selected()
	var pos := (Vector2(grid_position) + Vector2.ONE * 0.5) * Vector2(Board.TILE_WIDTH, Board.TILE_HEIGHT)
	_camera_settings(board.position + pos, _ZOOM_SELECTED, false)
	
	for p in movable_positions:
		var icon := Sprite2D.new()
		add_child(icon)
		icon.texture = _ICON_MOVE
		icon.position = board.position + Vector2(p * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))
		icon.position += Vector2(float(Board.TILE_WIDTH), float(Board.TILE_HEIGHT)) * 0.5
		icons.push_back(icon)
	
	for p in strikeable_positions:
		var icon := Sprite2D.new()
		add_child(icon)
		icon.texture = _ICON_STRIKE
		icon.position = board.position + Vector2(p * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))
		icon.position += Vector2(float(Board.TILE_WIDTH), float(Board.TILE_HEIGHT)) * 0.5
		icons.push_back(icon)


func _handle_click_move(
		button_index: MouseButton,
		grid_position: Vector2i,
		board: Board,
		selected_piece: Piece,
		movable_positions: Array[Vector2i],
		strikeable_positions: Array[Vector2i],
		icons: Array[Sprite2D],
) -> void:
	if grid_position in movable_positions:
		for icon in icons:
			icon.queue_free()
		selected_piece.mark_unselected()
		_click_func = _handle_click_root
		selected_piece.move(grid_position)
		_handled_pieces.push_back(selected_piece)
		selected_piece.mark_immovable()
	
	elif grid_position in strikeable_positions:
		for icon in icons:
			icon.queue_free()
		selected_piece.mark_unselected()
		_click_func = _handle_click_root
		board.get_piece(grid_position).kill()
		selected_piece.move(grid_position)
		_handled_pieces.push_back(selected_piece)
		selected_piece.mark_immovable()
	
	else:
		for icon in icons:
			icon.queue_free()
		selected_piece.mark_unselected()
		_click_func = _handle_click_root
	
	_camera_settings(_camera_position, _ZOOM_DEFAULT, true)
