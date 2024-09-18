class_name PlayerController
extends Controller


const _CAMERA_SPEED := 500.0
const _PAN_FACTOR := 25.0
const _ICON_MOVE := preload("res://assets/textures/icon_move.svg")
const _ICON_STRIKE := preload("res://assets/textures/icon_strike.svg")
const _ICON_MOVE_INTERFACE := preload("res://assets/textures/icon_move_interface.svg")
const _ICON_STRIKE_INTERFACE := preload("res://assets/textures/icon_strike_interface.svg")
const _ICON_POSSESS := preload("res://assets/textures/icon_possess.svg")
const _ZOOM_DEFAULT := 1.0
const _ZOOM_SELECTED := 1.1
const _TIME_COMPREHENSION := 0.5

@export var camera: Camera2D
@export var moves_per_turn := 1

var _handled_pieces: Array[Piece] = []
var _click_func = _handle_click_root
var _camera_position := Vector2.ZERO
var _camera_zoom := _ZOOM_DEFAULT
var _camera_free := true
var _remaining_moves := 0


func _ready() -> void:
	_camera_position = camera.position
	
	if get_parent() is World:
		for board in get_parent().get_boards():
			board.tile_clicked.connect(_on_tile_clicked.bind(board))


func _turn_begun() -> void:
	_remaining_moves = moves_per_turn


func _turn_ended() -> void:
	_remaining_moves = 0


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
	if _remaining_moves > 0:
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
	var movable_interfaces := selected_piece.get_movable_interfaces()
	var strikeable_interfaces := selected_piece.get_strikeable_interfaces()
	var icons: Array[Sprite2D] = []
	_click_func = _handle_click_move.bind(
		selected_piece,
		movable_positions,
		strikeable_positions,
		movable_interfaces,
		strikeable_interfaces,
		icons,
	)
	
	selected_piece.mark_selected()
	var pos := (Vector2(grid_position) + Vector2.ONE * 0.5) * Vector2(Board.TILE_WIDTH, Board.TILE_HEIGHT)
	var top_left := Vector2.INF
	var bot_right := -Vector2.INF
	
	for i in movable_interfaces:
		var icon := Sprite2D.new()
		add_child(icon)
		icon.texture = _ICON_MOVE_INTERFACE
		icon.position = i.to_board.position + Vector2(i.to_grid_position * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))
		icon.position += Vector2(float(Board.TILE_WIDTH), float(Board.TILE_HEIGHT)) * 0.5
		icons.push_back(icon)
		top_left = top_left.min(icon.position)
		bot_right = bot_right.max(icon.position)
	
	for i in strikeable_interfaces:
		var icon := Sprite2D.new()
		add_child(icon)
		icon.texture = _ICON_STRIKE_INTERFACE
		icon.position = i.to_board.position + Vector2(i.to_grid_position * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))
		icon.position += Vector2(float(Board.TILE_WIDTH), float(Board.TILE_HEIGHT)) * 0.5
		icons.push_back(icon)
		top_left = top_left.min(icon.position)
		bot_right = bot_right.max(icon.position)
	
	for p in movable_positions:
		var icon := Sprite2D.new()
		add_child(icon)
		icon.texture = _ICON_MOVE
		icon.position = board.position + Vector2(p * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))
		icon.position += Vector2(float(Board.TILE_WIDTH), float(Board.TILE_HEIGHT)) * 0.5
		icons.push_back(icon)
		top_left = top_left.min(icon.position)
		bot_right = bot_right.max(icon.position)
	
	for p in strikeable_positions:
		var icon := Sprite2D.new()
		add_child(icon)
		icon.texture = _ICON_STRIKE
		icon.position = board.position + Vector2(p * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))
		icon.position += Vector2(float(Board.TILE_WIDTH), float(Board.TILE_HEIGHT)) * 0.5
		icons.push_back(icon)
		top_left = top_left.min(icon.position)
		bot_right = bot_right.max(icon.position)
	
	top_left -= Vector2.ONE * 64.0
	bot_right += Vector2.ONE * 64.0
	var spread := bot_right - top_left
	var minimum_zoom := get_viewport().get_visible_rect().size / spread
	var minimum_zoom_factor := minf(minimum_zoom.x, minimum_zoom.y)
	
	var center := (top_left + bot_right) * 0.5
	_camera_settings(center, minf(minimum_zoom_factor, _ZOOM_SELECTED), false)
	print(_camera_zoom)


func _handle_click_move(
		button_index: MouseButton,
		grid_position: Vector2i,
		board: Board,
		selected_piece: Piece,
		movable_positions: Array[Vector2i],
		strikeable_positions: Array[Vector2i],
		movable_interfaces: Array[BoardInterface],
		strikeable_interfaces: Array[BoardInterface],
		icons: Array[Sprite2D],
) -> void:
	if not movable_interfaces.is_empty() and board == movable_interfaces[0].to_board and grid_position == movable_interfaces[0].to_grid_position:
		_remaining_moves -= 1
		selected_piece.move(movable_interfaces[0].to_grid_position, movable_interfaces[0].to_board)
		_handled_pieces.push_back(selected_piece)
		selected_piece.mark_immovable()
	
	elif not strikeable_interfaces.is_empty() and board == strikeable_interfaces[0].to_board and grid_position == strikeable_interfaces[0].to_grid_position:
		_remaining_moves -= 1
		strikeable_interfaces[0].to_board.get_piece(strikeable_interfaces[0].to_grid_position).kill()
		selected_piece.move(strikeable_interfaces[0].to_grid_position, strikeable_interfaces[0].to_board)
		_handled_pieces.push_back(selected_piece)
		selected_piece.mark_immovable()
	
	elif grid_position in movable_positions:
		_remaining_moves -= 1
		selected_piece.move(grid_position)
		_handled_pieces.push_back(selected_piece)
		selected_piece.mark_immovable()
	
	elif grid_position in strikeable_positions:
		_remaining_moves -= 1
		board.get_piece(grid_position).kill()
		selected_piece.move(grid_position)
		_handled_pieces.push_back(selected_piece)
		selected_piece.mark_immovable()
	
	for icon in icons:
		icon.queue_free()
	selected_piece.mark_unselected()
	_click_func = _handle_click_root
	_camera_settings(_camera_position, _ZOOM_DEFAULT, true)
	
	if _remaining_moves <= 0:
		for piece in _handled_pieces:
			_handled_pieces.erase(piece)
			piece.mark_movable()
		await get_tree().create_timer(_TIME_COMPREHENSION).timeout
		turn_passed.emit()
