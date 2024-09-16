class_name PlayerController
extends Controller


const _ICON_MOVE := preload("res://assets/textures/icon_move.svg")
const _ICON_STRIKE := preload("res://assets/textures/icon_strike.svg")
const _ICON_POSSESS := preload("res://assets/textures/icon_possess.svg")

var _handled_pieces: Array[Piece] = []
var _click_func = _handle_click_root


func _set_pieces(value: Array[Piece]) -> void:
	if not is_node_ready():
		await ready
	
	var added_pieces := value.filter(func(p: Piece): return p not in pieces)
	var removed_pieces := pieces.filter(func(p: Piece): return p not in value)
	
	for p in added_pieces:
		p.board.tile_clicked.connect(_on_tile_clicked.bind(p.board))
	
	for p in removed_pieces:
		p.board.tile_clicked.disconnect(_on_tile_clicked)


func _get_team() -> Piece.Team:
	return Piece.Team.BLACK


func _on_tile_clicked(button_index: MouseButton, grid_position: Vector2i, board: Board) -> void:
	_click_func.call(button_index, grid_position, board)


func _handle_click_root(button_index: MouseButton, grid_position: Vector2i, board: Board) -> void:
	var selected_piece := board.get_piece(grid_position)
	if selected_piece == null:
		return
	if selected_piece.team != get_team():
		return
	
	var movable_positions := selected_piece.get_movable_positions()
	var strikeable_positions := selected_piece.get_strikeable_positions()
	var icons: Array[Sprite2D] = []
	_click_func = _handle_click_move.bind(selected_piece, movable_positions, strikeable_positions, icons)
	
	selected_piece.scale = Vector2(0.5, 0.5)
	
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
		selected_piece.scale = Vector2(1.0, 1.0)
		_click_func = _handle_click_root
		selected_piece.grid_position = grid_position
	
	elif grid_position in strikeable_positions:
		for icon in icons:
			icon.queue_free()
		selected_piece.scale = Vector2(1.0, 1.0)
		_click_func = _handle_click_root
		board.get_piece(grid_position).queue_free()
		selected_piece.grid_position = grid_position
	
	else:
		for icon in icons:
			icon.queue_free()
		selected_piece.scale = Vector2(1.0, 1.0)
		_click_func = _handle_click_root
