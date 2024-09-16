class_name PlayerController
extends Controller


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
	print("A")
	_click_func = _handle_click_move


func _handle_click_move(button_index: MouseButton, grid_position: Vector2i, board: Board) -> void:
	print("B")
	_click_func = _handle_click_root
