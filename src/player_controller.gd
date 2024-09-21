class_name PlayerController
extends Controller

const _ICON_MOVE := preload("res://assets/textures/icon_move.svg")
const _ICON_STRIKE := preload("res://assets/textures/icon_strike.svg")
const _ICON_MOVE_INTERFACE := preload("res://assets/textures/icon_move_interface.svg")
const _ICON_STRIKE_INTERFACE := preload("res://assets/textures/icon_strike_interface.svg")
const _ICON_POSSESS := preload("res://assets/textures/icon_possess.svg")
const _SELECTION_HINT := preload("res://scenes/instantiables/selection_hint.tscn")
const _ZOOM_DEFAULT := 1.0
const _ZOOM_SELECTED := 1.1
const _TIME_COMPREHENSION := 1.0
const _REASON_HOVER_BOARD := 1
const _REASON_MY_TURN := 100
const _REASON_CUTSCENE := 101

@export var moves_per_turn := 1

var _world: World
var _camera_controller: CameraController
var _handled_pieces: Array[Piece] = []
var _click_func = _handle_click_root
var _move_count := 0
var _selection_hint := _SELECTION_HINT.instantiate()
var _reason_show_selection_hint = -_REASON_MY_TURN:
	set(v):
		_reason_show_selection_hint = v
		_selection_hint.visible = _reason_show_selection_hint > 0
		_selection_hint.z_index = 3


func _init() -> void:
	_selection_hint.visible = _reason_show_selection_hint > 0


func _enter_tree() -> void:
	super()
	add_child(_selection_hint, false, Node.INTERNAL_MODE_BACK)


func _ready() -> void:
	if get_parent() is World:
		_world = get_parent()
		_world.cutscene_begun.connect(_on_cutscene_begun)
		_world.cutscene_ended.connect(_on_cutscene_ended)
		_camera_controller = get_parent().get_camera_controller()
		for board in _world.get_boards():
			board.mouse_entered.connect(_on_mouse_entered.bind(board))
			board.mouse_exited.connect(_on_mouse_exited.bind(board))
			board.mouse_moved.connect(_on_mouse_moved.bind(board))
			board.tile_clicked.connect(_on_tile_clicked.bind(board))
	
	if _camera_controller == null:
		printerr("(%s) was not assigned a camera controller!" % self)


func _turn_begun() -> void:
	_handled_pieces = []
	
	if get_available_move_count() == 0:
		var remaining_pieces_count := 0
		for board in _world.get_boards():
			remaining_pieces_count += board.get_team_count(get_team())
		if remaining_pieces_count == 0:
			await get_tree().create_timer(_TIME_COMPREHENSION).timeout
			Hud.game_over(Hud.GameOver.NO_MATERIAL)
			return
		
		await get_tree().create_timer(_TIME_COMPREHENSION).timeout
		turn_passed.emit()
		return
	
	_move_count = 0
	_reason_show_selection_hint += _REASON_MY_TURN


func _turn_ended() -> void:
	_move_count = moves_per_turn
	_reason_show_selection_hint -= _REASON_MY_TURN


func _get_team() -> Piece.Team:
	return Piece.Team.BLACK


func _get_move_count() -> int:
	return _move_count


func _get_available_move_count() -> int:
	var moves := 0
	
	var pieces = get_tree().get_nodes_in_group(&"pieces")
	var my_pieces = pieces.filter(func(p): return p.team == get_team())
	
	for p: Piece in my_pieces:
		moves += len(p.get_movable_interfaces())
		moves += len(p.get_strikeable_interfaces())
		moves += len(p.get_movable_positions())
		moves += len(p.get_strikeable_positions())
	
	return moves


func _on_cutscene_begun() -> void:
	_reason_show_selection_hint += _REASON_CUTSCENE


func _on_cutscene_ended() -> void:
	_reason_show_selection_hint -= _REASON_CUTSCENE


func _on_mouse_entered(board: Board) -> void:
	_reason_show_selection_hint += _REASON_HOVER_BOARD


func _on_mouse_exited(board: Board) -> void:
	_reason_show_selection_hint -= _REASON_HOVER_BOARD


func _on_mouse_moved(grid_position: Vector2i, board: Board) -> void:
	_selection_hint.position = board.position + Vector2(grid_position * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))


func _on_tile_clicked(button_index: MouseButton, grid_position: Vector2i, board: Board) -> void:
	if not _selection_hint.visible:
		return
	if _move_count < moves_per_turn:
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
	var possessable_positions := selected_piece.get_possessable_positions()
	var movable_interfaces := selected_piece.get_movable_interfaces()
	var strikeable_interfaces := selected_piece.get_strikeable_interfaces()
	var possessable_interfaces := selected_piece.get_possessable_interfaces()
	var icons: Array[Sprite2D] = []
	_click_func = _handle_click_move.bind(
		selected_piece,
		movable_positions,
		strikeable_positions,
		possessable_positions,
		movable_interfaces,
		strikeable_interfaces,
		possessable_interfaces,
		icons,
	)
	
	selected_piece.mark_selected()
	var pos := (Vector2(grid_position) + Vector2.ONE * 0.5) * Vector2(Board.TILE_WIDTH, Board.TILE_HEIGHT)
	var top_left := selected_piece.global_position
	var bot_right := selected_piece.global_position
	
	for i in movable_interfaces:
		var icon := Sprite2D.new()
		add_child(icon)
		icon.texture = _ICON_MOVE_INTERFACE
		icon.position = i.to_board.position + Vector2(i.to_grid_position * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))
		icon.position += Vector2(float(Board.TILE_WIDTH), float(Board.TILE_HEIGHT)) * 0.5
		icon.z_index = 3
		icons.push_back(icon)
		top_left = top_left.min(icon.position)
		bot_right = bot_right.max(icon.position)
	
	for i in strikeable_interfaces:
		var icon := Sprite2D.new()
		add_child(icon)
		icon.texture = _ICON_STRIKE_INTERFACE
		icon.position = i.to_board.position + Vector2(i.to_grid_position * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))
		icon.position += Vector2(float(Board.TILE_WIDTH), float(Board.TILE_HEIGHT)) * 0.5
		icon.z_index = 3
		icons.push_back(icon)
		top_left = top_left.min(icon.position)
		bot_right = bot_right.max(icon.position)
	
	for i in possessable_interfaces:
		var icon := Sprite2D.new()
		add_child(icon)
		icon.texture = _ICON_POSSESS
		icon.position = i.to_board.position + Vector2(i.to_grid_position * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))
		icon.position += Vector2(float(Board.TILE_WIDTH), float(Board.TILE_HEIGHT)) * 0.5
		icon.z_index = 3
		icons.push_back(icon)
		top_left = top_left.min(icon.position)
		bot_right = bot_right.max(icon.position)
	
	for p in movable_positions:
		var icon := Sprite2D.new()
		add_child(icon)
		icon.texture = _ICON_MOVE
		icon.position = board.position + Vector2(p * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))
		icon.position += Vector2(float(Board.TILE_WIDTH), float(Board.TILE_HEIGHT)) * 0.5
		icon.z_index = 3
		icons.push_back(icon)
		top_left = top_left.min(icon.position)
		bot_right = bot_right.max(icon.position)
	
	for p in strikeable_positions:
		var icon := Sprite2D.new()
		add_child(icon)
		icon.texture = _ICON_STRIKE
		icon.position = board.position + Vector2(p * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))
		icon.position += Vector2(float(Board.TILE_WIDTH), float(Board.TILE_HEIGHT)) * 0.5
		icon.z_index = 3
		icons.push_back(icon)
		top_left = top_left.min(icon.position)
		bot_right = bot_right.max(icon.position)
	
	for p in possessable_positions:
		var icon := Sprite2D.new()
		add_child(icon)
		icon.texture = _ICON_POSSESS
		icon.position = board.position + Vector2(p * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT))
		icon.position += Vector2(float(Board.TILE_WIDTH), float(Board.TILE_HEIGHT)) * 0.5
		icon.z_index = 3
		icons.push_back(icon)
		top_left = top_left.min(icon.position)
		bot_right = bot_right.max(icon.position)
	
	top_left -= Vector2.ONE * 64.0
	bot_right += Vector2.ONE * 64.0
	var spread := bot_right - top_left
	var minimum_zoom := get_viewport().get_visible_rect().size / spread
	var minimum_zoom_factor := minf(minimum_zoom.x, minimum_zoom.y)
	
	var center := (top_left + bot_right) * 0.5
	_camera_controller.settings(center, minf(minimum_zoom_factor, _ZOOM_SELECTED), false)


func _handle_click_move(
		button_index: MouseButton,
		grid_position: Vector2i,
		board: Board,
		selected_piece: Piece,
		movable_positions: Array[Vector2i],
		strikeable_positions: Array[Vector2i],
		possessable_positions: Array[Vector2i],
		movable_interfaces: Array[BoardInterface],
		strikeable_interfaces: Array[BoardInterface],
		possessable_interfaces: Array[BoardInterface],
		icons: Array[Sprite2D],
) -> void:
	var new_selected_piece := board.get_piece(grid_position)
	
	if new_selected_piece != null and new_selected_piece != selected_piece and new_selected_piece.team == get_team() and new_selected_piece not in _handled_pieces:
		_handle_click_root.call_deferred(button_index, grid_position, board)
	
	elif not movable_interfaces.is_empty() and board == movable_interfaces[0].to_board and grid_position == movable_interfaces[0].to_grid_position:
		_move_count += 1
		selected_piece.move(movable_interfaces[0].to_grid_position, movable_interfaces[0].to_board)
		_handled_pieces.push_back(selected_piece)
		selected_piece.mark_immovable()
		_camera_controller.set_position(selected_piece.position)
	
	elif not strikeable_interfaces.is_empty() and board == strikeable_interfaces[0].to_board and grid_position == strikeable_interfaces[0].to_grid_position:
		_move_count += 1
		strikeable_interfaces[0].to_board.get_piece(strikeable_interfaces[0].to_grid_position).kill()
		selected_piece.move(strikeable_interfaces[0].to_grid_position, strikeable_interfaces[0].to_board)
		_handled_pieces.push_back(selected_piece)
		selected_piece.mark_immovable()
		_camera_controller.set_position(selected_piece.position)
	
	elif not possessable_interfaces.is_empty() and board == possessable_interfaces[0].to_board and grid_position == possessable_interfaces[0].to_grid_position:
		_move_count += 1
		selected_piece.convert(possessable_interfaces[0].to_grid_position, possessable_interfaces[0].to_board)
		_camera_controller.set_position(new_selected_piece.position)
		_camera_controller.set_zoom(_ZOOM_SELECTED)
		selected_piece.kill()
	
	elif grid_position in movable_positions:
		_move_count += 1
		selected_piece.move(grid_position)
		_handled_pieces.push_back(selected_piece)
		selected_piece.mark_immovable()
		_camera_controller.set_position(selected_piece.position)
	
	elif grid_position in strikeable_positions:
		_move_count += 1
		board.get_piece(grid_position).kill()
		selected_piece.move(grid_position)
		_handled_pieces.push_back(selected_piece)
		selected_piece.mark_immovable()
		_camera_controller.set_position(selected_piece.position)
	
	elif grid_position in possessable_positions:
		_move_count += 1
		selected_piece.convert_piece(grid_position)
		_camera_controller.set_position(new_selected_piece.position)
		_camera_controller.set_zoom(_ZOOM_SELECTED)
		selected_piece.kill()
	
	for icon in icons:
		icon.queue_free()
	selected_piece.mark_unselected()
	_click_func = _handle_click_root
	
	_camera_controller.set_position(board.position + Vector2(grid_position) * Vector2(Board.TILE_WIDTH, Board.TILE_HEIGHT) + Vector2(Board.TILE_WIDTH, Board.TILE_HEIGHT) * 0.5)
	await get_tree().create_timer(_TIME_COMPREHENSION).timeout
	_camera_controller.reset_zoom()
	_camera_controller.set_free(true)
	
	if get_available_move_count() == 0:
		await get_tree().create_timer(_TIME_COMPREHENSION).timeout
		turn_passed.emit()
		return
	
	elif _move_count >= moves_per_turn:
		for piece in _handled_pieces:
			_handled_pieces.erase(piece)
			piece.mark_movable()
		await get_tree().create_timer(_TIME_COMPREHENSION).timeout
		turn_passed.emit()
