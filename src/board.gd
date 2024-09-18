@tool
class_name Board
extends Node2D


signal tile_clicked(button_index: MouseButton, grid_position: Vector2i)
signal state_changed

const TILE_WIDTH := 64.0
const TILE_HEIGHT := 48.0
const _MASK_TYPE := 0b0000_1111
const _MASK_TEAM := 0b1111_0000
const _BOARD_TEXTURE := preload("res://assets/textures/board.png")
const _BOARD_SHADER := preload("res://shaders/repeat.gdshader")
const _GRADIENT_SHADER := preload("res://shaders/rect_edge_distance_alpha_gradient.gdshader")
const _PINCH_SHADER := preload("res://shaders/pinch.gdshader")
const _SELECTION_HINT := preload("res://scenes/instantiables/selection_hint.tscn")
const _TIME_COMPREHENSION := 1.0

@export var size := Vector2i(8, 8):
	set(value):
		size = value
		_update_size()
## When this team reports having 0 pieces on the board, unlock all interfaces
@export var interfaces_adverse_team := Piece.Team.WHITE

var _board_state := PackedByteArray()
var _sprite := Sprite2D.new()
var _gradient := ColorRect.new()
var _click_area := ClickArea.new()
var _click_area_shape := CollisionShape2D.new()
var _selection_hint := _SELECTION_HINT.instantiate()
var _interfaces: Array[Node]
var _team_count := { Piece.Team.WHITE: 0, Piece.Team.BLACK: 0 }



func _init() -> void:
	_sprite.centered = false
	_sprite.texture = _BOARD_TEXTURE
	_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_sprite.material = ShaderMaterial.new()
	_sprite.material.shader = _BOARD_SHADER
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	_gradient.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gradient.color = Color.BLACK
	_gradient.material = ShaderMaterial.new()
	_gradient.material.shader = _GRADIENT_SHADER
	_gradient.show_behind_parent = true
	
	_click_area.clicked.connect(_on_clicked)
	_click_area.mouse_entered.connect(_selection_hint.show)
	_click_area.mouse_exited.connect(_selection_hint.hide)
	_click_area.mouse_moved.connect(_on_mouse_moved)
	
	_click_area_shape.shape = RectangleShape2D.new()
	
	_selection_hint.hide()
	
	_update_size()


func _enter_tree() -> void:
	if _sprite.get_parent() == null:
		add_child(_sprite, false, Node.INTERNAL_MODE_BACK)
	
	if _gradient.get_parent() == null:
		add_child(_gradient, false, Node.INTERNAL_MODE_BACK)
	
	if Engine.is_editor_hint():
		return
	
	if _click_area.get_parent() == null:
		add_child(_click_area, false, Node.INTERNAL_MODE_BACK)
	
	if _click_area_shape.get_parent() == null:
		_click_area.add_child(_click_area_shape, false, Node.INTERNAL_MODE_BACK)
	
	if _selection_hint.get_parent() == null:
		add_child(_selection_hint, false, Node.INTERNAL_MODE_BACK)
	
	if get_parent() is World:
		get_parent().register_board(self)
	
	_click_area_shape.shape.size.x = size.x * TILE_WIDTH
	_click_area_shape.shape.size.y = size.y * TILE_HEIGHT
	_click_area_shape.position.x = float(size.x * TILE_WIDTH) * 0.5
	_click_area_shape.position.y = float(size.y * TILE_HEIGHT) * 0.5
	
	reload_board_state()


func _ready() -> void:
	_interfaces = get_children().filter(func(c): return c is BoardInterface)


func _update_size() -> void:
	_sprite.scale = Vector2(size) * 0.5
	_sprite.material.set_shader_parameter(&"scale", _sprite.scale)
	_gradient.position = -Vector2(TILE_WIDTH, TILE_HEIGHT)
	_gradient.size = (size + Vector2i(2, 2)) * Vector2i(TILE_WIDTH, TILE_HEIGHT)


func _on_clicked(button_index: MouseButton, click_position: Vector2) -> void:
	var p := get_global_mouse_position() - position
	var g := Vector2i(p / Vector2(TILE_WIDTH, TILE_HEIGHT))
	print("Clicked %s %s %s" % [button_index, click_position, g])
	tile_clicked.emit(button_index, g)


func _on_mouse_moved(mouse_position: Vector2) -> void:
	var p := get_global_mouse_position() - position
	var g := Vector2i(p / Vector2(TILE_WIDTH, TILE_HEIGHT))
	_selection_hint.position = position + Vector2(g * Vector2i(TILE_WIDTH, TILE_HEIGHT))


func reload_board_state() -> void:
	_board_state.resize(size.x * size.y)
	state_changed.emit()


func is_in_board(grid_position: Vector2i) -> bool:
	var x := grid_position.x
	var y := grid_position.y
	return x >= 0 and x < size.x and y >= 0 and y < size.y


func is_open(grid_position: Vector2i) -> bool:
	if not is_in_board(grid_position):
		return false
	return _board_state[grid_position.x + grid_position.y * size.x] & 15 == 0


func get_piece_type(grid_position: Vector2i) -> Piece.Type:
	if not is_in_board(grid_position):
		return Piece.Type.WALL
	var s := _board_state[grid_position.x + grid_position.y * size.x]
	return (s & _MASK_TYPE) as Piece.Type


func get_piece_team(grid_position: Vector2i) -> Piece.Team:
	if not is_in_board(grid_position):
		return Piece.Team.NEUTRAL
	var s := _board_state[grid_position.x + grid_position.y * size.x]
	return (s & _MASK_TEAM) >> 4 as Piece.Team


func get_piece(grid_position: Vector2i) -> Node:
	var pieces := get_tree().get_nodes_in_group(&"pieces")
	for n in pieces:
		if n.board == self and n.grid_position == grid_position:
			return n
	return null


func set_piece(grid_position: Vector2i, type: Piece.Type, team: Piece.Team) -> void:
	var type_int := int(type) & _MASK_TYPE
	var team_int := (int(team) << 4) & _MASK_TEAM
	_board_state[grid_position.x + grid_position.y * size.x] = type_int + team_int
	state_changed.emit()


func clear_piece(grid_position: Vector2i) -> void:
	_board_state[grid_position.x + grid_position.y * size.x] = 0
	state_changed.emit()


func is_piece_strikeable(grid_position: Vector2i, striker_team: Piece.Team) -> bool:
	if not is_in_board(grid_position):
		return false
	if get_piece_type(grid_position) == 0:
		return false
	var victim_team := get_piece_team(grid_position)
	return Piece.can_team_strike_team(striker_team, victim_team)


func get_interface(grid_position: Vector2i) -> BoardInterface:
	for interface in _interfaces:
		if interface.grid_position == grid_position:
			return interface
	return null


func unlock_interfaces() -> void:
	for interface in _interfaces:
		interface.unlock()


func report_increase(team: Piece.Team) -> void:
	if team not in _team_count:
		_team_count[team] = 0
	_team_count[team] += 1


func report_decrease(team: Piece.Team) -> void:
	if team not in _team_count:
		_team_count[team] = 0
		printerr("Should not be reporting a decrease in team count that has not before reported an increase.")
	_team_count[team] -= 1
	
	if _team_count[interfaces_adverse_team] == 0:
		await get_tree().create_timer(_TIME_COMPREHENSION).timeout
		unlock_interfaces()
