@tool
class_name Piece
extends Node2D


enum Team {
	WHITE,
	BLACK,
	NEUTRAL,
}

enum Type {
	PAWN = 1,
	KNIGHT,
	BISHOP,
	ROOK,
	QUEEN,
	KING,
	
	WALL,
}

enum Power {
	POSSESS,
}

const _DELTAS_KNIGHT: Array[Vector2i] = [
	Vector2i(-1, -2),
	Vector2i(1, -2),
	Vector2i(2, -1),
	Vector2i(1, 2),
	Vector2i(2, 1),
	Vector2i(-1, 2),
	Vector2i(-2, -1),
	Vector2i(-2, 1),
]

const _DELTAS_BISHOP: Array[Vector2i] = [
	Vector2i(-1, -1),
	Vector2i(1, -1),
	Vector2i(1, 1),
	Vector2i(-1, 1),
]

const _DELTAS_ROOK: Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 0),
]

const _DELTAS_ROYALTY: Array[Vector2i] = [
	Vector2i(-1, -1),
	Vector2i(0, -1),
	Vector2i(1, -1),
	Vector2i(1, 0),
	Vector2i(1, 1),
	Vector2i(0, 1),
	Vector2i(-1, 1),
	Vector2i(-1, 0),
]

const _DISTANCE_BISHOP := 7
const _DISTANCE_ROOK := 7
const _DISTANCE_QUEEN := 7
const _DISTANCE_KING := 1
const _ANIM_TIME_PIECE_MOVE := 0.5
const _ANIM_TIME_PIECE_KILL := 1.0

@export var team := Team.WHITE:
	set(v):
		team = v
		clear_caches()
		if board and not Engine.is_editor_hint():
			board.set_piece(grid_position, type, team)
		_update_sprite()
@export var type := Type.PAWN:
	set(v):
		type = v
		_is_pawn = type == Type.PAWN
		clear_caches()
		if board and not Engine.is_editor_hint():
			board.set_piece(grid_position, type, team)
		_update_sprite()
@export var direction := Direction.Cardinal.NORTH:
	set(v):
		direction = v
		clear_caches()
		_update_sprite()
@export var grid_position := Vector2i.ZERO:
	set(v):
		#if board and not Engine.is_editor_hint():
			#board.clear_piece(grid_position)
		grid_position = v
		clear_caches()
		_update_sprite()
		_update_position()
@export var move_count := 0:
	set(v):
		move_count = v
		clear_caches()
@export var board: Board:
	set(v):
		if board != null:
			board.report_decrease(team)
			board.state_changed.disconnect(clear_caches)
		board = v
		if board != null:
			board.report_increase(team)
			board.state_changed.connect(clear_caches)
		clear_caches()
		_update_position()
@export var powers: Array[Power] = []

var _docache_movable_positions := false
var _cache_movable_positions: Array[Vector2i] = []
var _docache_strikeable_positions := false
var _cache_strikeable_positions: Array[Vector2i] = []
var _docache_possessable_positions := false
var _cache_possessable_positions: Array[Vector2i] = []
var _is_pawn := type == Type.PAWN:
	set(v):
		_is_pawn = v
		_update_sprite()
var _is_moving := false:
	set(v):
		_is_moving = v
		_update_sprite()

@onready var _sprite := $Sprite2D
@onready var _shadow := $Shadow
@onready var _direction_hint := $DirectionHint
@onready var _particles_smoke_0 = $ParticlesSmoke0
@onready var _particles_smoke_1 = $ParticlesSmoke1
@onready var _power_hint := $Sprite2D/PowerHint


func _ready() -> void:
	_update_position()
	_update_sprite()


func _update_position() -> void:
	if not is_node_ready():
		await ready
	
	if board == null:
		printerr("Piece (%s) is not associated with a board." % self)
		return
	
	position = board.position + Vector2(grid_position) * Vector2(Board.TILE_WIDTH, Board.TILE_HEIGHT)
	position += Vector2(float(Board.TILE_WIDTH) * 0.5, float(Board.TILE_HEIGHT))
	
	if not board.is_in_board(grid_position):
		printerr("Piece (%s) is not inside board!" % self)
		return
	
	if not Engine.is_editor_hint():
		board.set_piece(grid_position, type, team)


func _update_sprite() -> void:
	if not is_node_ready():
		await ready
	
	_sprite.frame_coords.x = clampi(int(type) - 1, 0, 5)
	_sprite.frame_coords.y = clampi(int(team), 0, 1)
	var c := "w" if (grid_position.x + grid_position.y) % 2 == 0 else "b"
	_direction_hint.play(str(direction) + "_" + c)
	_direction_hint.visible = _is_pawn and not _is_moving
	
	var was_power_hint_visible = _power_hint.visible
	_power_hint.visible = not powers.is_empty()
	
	if _power_hint.visible != was_power_hint_visible:
		var spm: Callable = func(x: float): _power_hint.material.set_shader_parameter(&"ball_size", x)
		var tween := get_tree().create_tween()
		if _power_hint.visible:
			tween.tween_method(spm, 0.0, 1.0, 1.0) \
				.set_trans(Tween.TRANS_CIRC) \
				.set_ease(Tween.EASE_OUT_IN)
		else:
			tween.tween_method(spm, 1.0, 0.0, 1.0) \
				.set_trans(Tween.TRANS_CIRC) \
				.set_ease(Tween.EASE_OUT)


func _on_land() -> void:
	var p := board.get_power_plate(grid_position)
	if p != null:
		add_power(p.power)
		p.queue_free()
	_update_sprite()


func get_movable_positions() -> Array[Vector2i]:
	if board == null:
		return []
	
	if _docache_movable_positions:
		return _cache_movable_positions
	
	_cache_movable_positions = []
	
	match type:
		Type.PAWN:
			var p0 := grid_position + Direction.vector(direction)
			var p1 := grid_position + Direction.vector(direction) * 2
			
			if board.is_open(p0):
				_cache_movable_positions.push_back(p0)
				if move_count == 0 and board.is_open(p1):
					_cache_movable_positions.push_back(grid_position + Direction.vector(direction) * 2)
		
		Type.KNIGHT:
			for d in _DELTAS_KNIGHT:
				var p := grid_position + d
				if board.is_open(p):
					_cache_movable_positions.push_back(p)
		
		Type.BISHOP:
			for d in _DELTAS_BISHOP:
				for i in _DISTANCE_BISHOP:
					var p: Vector2i = grid_position + d * (i  + 1)
					if not board.is_open(p):
						break
					_cache_movable_positions.push_back(p)
		
		Type.ROOK:
			for d in _DELTAS_ROOK:
				for i in _DISTANCE_ROOK:
					var p: Vector2i = grid_position + d * (i  + 1)
					if not board.is_open(p):
						break
					_cache_movable_positions.push_back(p)
		
		Type.QUEEN:
			for d in _DELTAS_ROYALTY:
				for i in _DISTANCE_QUEEN:
					var p: Vector2i = grid_position + d * (i  + 1)
					if not board.is_open(p):
						break
					_cache_movable_positions.push_back(p)
		
		Type.KING:
			for d in _DELTAS_ROYALTY:
				for i in _DISTANCE_KING:
					var p: Vector2i = grid_position + d * (i  + 1)
					if board.is_open(p):
						_cache_movable_positions.push_back(p)
	
	_docache_movable_positions = true
	return _cache_movable_positions


func get_strikeable_positions() -> Array[Vector2i]:
	if board == null:
		return []
	
	if has_power(Power.POSSESS):
		return []
	
	if _docache_strikeable_positions:
		return _cache_strikeable_positions
	
	_cache_strikeable_positions = []
	
	match type:
		Type.PAWN:
			var f := grid_position + Direction.vector(direction)
			var p0 := Direction.move(f, direction, Direction.Relative.LEFT)
			var p1 := Direction.move(f, direction, Direction.Relative.RIGHT)
			
			if board.is_piece_strikeable(p0, team):
				_cache_strikeable_positions.push_back(p0)
			
			if board.is_piece_strikeable(p1, team):
				_cache_strikeable_positions.push_back(p1)
		
		Type.KNIGHT:
			for d in _DELTAS_KNIGHT:
				var p := grid_position + d
				if board.is_piece_strikeable(p, team):
					_cache_strikeable_positions.push_back(p)
		
		Type.BISHOP:
			for d in _DELTAS_BISHOP:
				for i in _DISTANCE_BISHOP:
					var p: Vector2i = grid_position + d * (i + 1)
					if board.is_piece_strikeable(p, team):
						_cache_strikeable_positions.push_back(p)
						break
					elif not board.is_open(p):
						break
		
		Type.ROOK:
			for d in _DELTAS_ROOK:
				for i in _DISTANCE_ROOK:
					var p: Vector2i = grid_position + d * (i + 1)
					if board.is_piece_strikeable(p, team):
						_cache_strikeable_positions.push_back(p)
						break
					elif not board.is_open(p):
						break
		
		Type.QUEEN:
			for d in _DELTAS_ROYALTY:
				for i in _DISTANCE_QUEEN:
					var p: Vector2i = grid_position + d * (i + 1)
					if board.is_piece_strikeable(p, team):
						_cache_strikeable_positions.push_back(p)
						break
					elif not board.is_open(p):
						break
		
		Type.KING:
			for d in _DELTAS_ROYALTY:
				for i in _DISTANCE_KING:
					var p: Vector2i = grid_position + d * (i + 1)
					if board.is_piece_strikeable(p, team):
						_cache_strikeable_positions.push_back(p)
						break
					elif not board.is_open(p):
						break
	
	_docache_strikeable_positions = true
	return _cache_strikeable_positions


func get_possessable_positions() -> Array[Vector2i]:
	if board == null:
		return []
	
	if not has_power(Power.POSSESS):
		return []
	
	if _docache_possessable_positions:
		return _cache_possessable_positions
	
	_cache_possessable_positions = []
	
	match type:
		Type.PAWN:
			var f := grid_position + Direction.vector(direction)
			var p0 := Direction.move(f, direction, Direction.Relative.LEFT)
			var p1 := Direction.move(f, direction, Direction.Relative.RIGHT)
			
			if board.is_piece_strikeable(p0, team):
				_cache_possessable_positions.push_back(p0)
			
			if board.is_piece_strikeable(p1, team):
				_cache_possessable_positions.push_back(p1)
		
		Type.KNIGHT:
			for d in _DELTAS_KNIGHT:
				var p := grid_position + d
				if board.is_piece_strikeable(p, team):
					_cache_possessable_positions.push_back(p)
		
		Type.BISHOP:
			for d in _DELTAS_BISHOP:
				for i in _DISTANCE_BISHOP:
					var p: Vector2i = grid_position + d * (i + 1)
					if board.is_piece_strikeable(p, team):
						_cache_possessable_positions.push_back(p)
						break
					elif not board.is_open(p):
						break
		
		Type.ROOK:
			for d in _DELTAS_ROOK:
				for i in _DISTANCE_ROOK:
					var p: Vector2i = grid_position + d * (i + 1)
					if board.is_piece_strikeable(p, team):
						_cache_possessable_positions.push_back(p)
						break
					elif not board.is_open(p):
						break
		
		Type.QUEEN:
			for d in _DELTAS_ROYALTY:
				for i in _DISTANCE_QUEEN:
					var p: Vector2i = grid_position + d * (i + 1)
					if board.is_piece_strikeable(p, team):
						_cache_possessable_positions.push_back(p)
						break
					elif not board.is_open(p):
						break
		
		Type.KING:
			for d in _DELTAS_ROYALTY:
				for i in _DISTANCE_KING:
					var p: Vector2i = grid_position + d * (i + 1)
					if board.is_piece_strikeable(p, team):
						_cache_possessable_positions.push_back(p)
						break
					elif not board.is_open(p):
						break
	
	_docache_possessable_positions = true
	return _cache_possessable_positions


func get_movable_interfaces() -> Array[BoardInterface]:
	if board == null:
		return []
	
	var interface := board.get_interface(grid_position)
	if interface == null:
		return []
	
	if interface.is_locked():
		return []
	
	if not interface.to_board.is_open(interface.to_grid_position):
		return []
	
	return [interface]


func get_strikeable_interfaces() -> Array[BoardInterface]:
	if board == null:
		return []
	
	if has_power(Power.POSSESS):
		return []
	
	var interface := board.get_interface(grid_position)
	if interface == null:
		return []
	
	if interface.is_locked():
		return []
	
	if interface.to_board.is_open(interface.to_grid_position):
		return []
	
	if not interface.to_board.is_piece_strikeable(interface.to_grid_position, team):
		return []
	
	return [interface]


func get_possessable_interfaces() -> Array[BoardInterface]:
	if board == null:
		return []
	
	if not has_power(Power.POSSESS):
		return []
	
	var interface := board.get_interface(grid_position)
	if interface == null:
		return []
	
	if interface.is_locked():
		return []
	
	if interface.to_board.is_open(interface.to_grid_position):
		return []
	
	if not interface.to_board.is_piece_strikeable(interface.to_grid_position, team):
		return []
	
	return [interface]


func clear_caches() -> void:
	_docache_movable_positions = false
	_docache_strikeable_positions = false
	_docache_possessable_positions = false


func mark_selected() -> void:
	_sprite.scale = Vector2(0.5, 0.5)
	_shadow.scale = Vector2(0.5, 0.5)


func mark_unselected() -> void:
	_sprite.scale = Vector2(1.0, 1.0)
	_shadow.scale = Vector2(1.0, 1.0)


func mark_movable() -> void:
	_sprite.modulate = Color.WHITE


func mark_immovable() -> void:
	_sprite.modulate = Color("707070")


func move(to: Vector2i, to_board: Board = null) -> void:
	board.clear_piece(grid_position)
	if to_board != null:
		board = to_board
	var pi := position
	grid_position = to
	var pf := position
	
	_shadow.position = pi - pf
	_sprite.position = pi - pf
	var anim_time := _ANIM_TIME_PIECE_MOVE
	var jump_y = min(_sprite.position.y - 16.0, -16.0)
	
	_is_moving = true
	move_count += 1
	
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(_sprite, ^"position:x", 0.0, anim_time) \
			.set_trans(Tween.TRANS_EXPO) \
			.set_ease(Tween.EASE_OUT)
	tween.tween_property(_shadow, ^"position:x", 0.0, anim_time) \
			.set_trans(Tween.TRANS_EXPO) \
			.set_ease(Tween.EASE_OUT)
	tween.tween_property(_shadow, ^"position:y", 0.0, anim_time * 0.5) \
			.set_trans(Tween.TRANS_EXPO) \
			.set_ease(Tween.EASE_IN)
	tween.tween_property(_sprite, ^"position:y", jump_y, anim_time * 0.5) \
			.set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_IN)
	tween.tween_property(_sprite, ^"position:y", 0.0, anim_time * 0.5) \
			.set_delay(anim_time * 0.5) \
			.set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_IN)
	tween.tween_property(_particles_smoke_0, ^"emitting", true, 0.0) \
			.set_delay(anim_time)
	tween.tween_property(_particles_smoke_1, ^"emitting", true, 0.0) \
			.set_delay(anim_time)
	tween.tween_property(self, ^"_is_moving", false, 0.0) \
			.set_delay(anim_time)
	tween.tween_callback(_on_land) \
			.set_delay(anim_time)


func convert_piece(to: Vector2i, to_board: Board = null) -> void:
	if to_board == null:
		to_board = board
	
	var piece := to_board.get_piece(to)
	to_board.report_conversion(piece.team, team)
	
	var delta: Vector2 = piece.position - position
	
	var anim_time := _ANIM_TIME_PIECE_MOVE
	var spm: Callable = func(x: float): _power_hint.material.set_shader_parameter(&"ball_size", x)
	
	var tween := get_tree().create_tween()
	tween.tween_property(_power_hint, ^"position", _power_hint.position + delta, anim_time * 0.5) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_method(spm, 1.0, 0.0, anim_time * 0.5)
	tween.tween_property(piece, ^"team", team, 0.0)
	tween.set_parallel(true)
	tween.tween_property(piece._particles_smoke_0, ^"emitting", true, 0.0)
	tween.tween_property(piece._particles_smoke_1, ^"emitting", true, 0.0)


func kill() -> void:
	if board != null:
		board.clear_piece(grid_position)
	board = null
	
	var move_time := _ANIM_TIME_PIECE_MOVE
	var kill_time := _ANIM_TIME_PIECE_KILL
	
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_callback(_shadow.hide) \
			.set_delay(move_time)
	tween.tween_callback(_direction_hint.hide) \
			.set_delay(move_time)
	tween.tween_property(_particles_smoke_0, ^"emitting", true, 0.0) \
			.set_delay(move_time)
	tween.tween_property(_particles_smoke_1, ^"emitting", true, 0.0) \
			.set_delay(move_time)
	tween.tween_property(_sprite, ^"modulate:a", 0.0, kill_time) \
			.set_delay(move_time)
	tween.tween_property(_sprite, ^"scale", Vector2(2.0, 2.0), kill_time) \
			.set_delay(move_time)
	tween.tween_property(_sprite, ^"rotation", randf_range(-PI, PI), kill_time) \
			.set_delay(move_time)
	tween.tween_callback(queue_free) \
			.set_delay(move_time + kill_time)


func add_power(power: Power) -> void:
	powers.push_back(power)


func has_power(power: Power) -> bool:
	return power in powers


static func can_team_strike_team(striker_team: Team, victim_team: Team) -> bool:
	match striker_team:
		Team.WHITE:
			return victim_team == Team.BLACK
		Team.BLACK:
			return victim_team == Team.WHITE
	return false
