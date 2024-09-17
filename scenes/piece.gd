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
		clear_caches()
		if board and not Engine.is_editor_hint():
			board.set_piece(grid_position, type, team)
		_update_sprite()
@export var direction := Direction.Cardinal.NORTH:
	set(v):
		direction = v
		clear_caches()
@export var grid_position := Vector2i.ZERO:
	set(v):
		if board and not Engine.is_editor_hint():
			board.clear_piece(grid_position)
		grid_position = v
		clear_caches()
		_update_position()
@export var move_count := 0:
	set(v):
		move_count = v
		clear_caches()
@export var board: Board:
	set(v):
		if board != null:
			board.state_changed.disconnect(clear_caches)
		board = v
		if board != null:
			board.state_changed.connect(clear_caches)
		clear_caches()
		_update_position()

var _docache_movable_positions := false
var _cache_movable_positions: Array[Vector2i] = []
var _docache_strikeable_positions := false
var _cache_strikeable_positions: Array[Vector2i] = []

@onready var _sprite := $Sprite2D
@onready var _shadow := $Shadow
@onready var _particles_smoke_0 = $ParticlesSmoke0
@onready var _particles_smoke_1 = $ParticlesSmoke1


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
	
	board.set_piece(grid_position, type, team)


func _update_sprite() -> void:
	if not is_node_ready():
		await ready
	
	_sprite.frame_coords.x = clampi(int(type) - 1, 0, 5)
	_sprite.frame_coords.y = clampi(int(team), 0, 1)


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
		
		Type.ROOK:
			for d in _DELTAS_ROOK:
				for i in _DISTANCE_ROOK:
					var p: Vector2i = grid_position + d * (i + 1)
					if board.is_piece_strikeable(p, team):
						_cache_strikeable_positions.push_back(p)
						break
		
		Type.QUEEN:
			for d in _DELTAS_ROYALTY:
				for i in _DISTANCE_QUEEN:
					var p: Vector2i = grid_position + d * (i + 1)
					if board.is_piece_strikeable(p, team):
						_cache_strikeable_positions.push_back(p)
						break
		
		Type.KING:
			for d in _DELTAS_ROYALTY:
				for i in _DISTANCE_KING:
					var p: Vector2i = grid_position + d * (i + 1)
					if board.is_piece_strikeable(p, team):
						_cache_strikeable_positions.push_back(p)
						break
	
	return _cache_strikeable_positions


func clear_caches() -> void:
	_docache_movable_positions = false
	_docache_strikeable_positions = false


func mark_selected() -> void:
	scale = Vector2(0.5, 0.5)


func mark_unselected() -> void:
	scale = Vector2(1.0, 1.0)


func mark_movable() -> void:
	_sprite.modulate = Color.WHITE


func mark_immovable() -> void:
	_sprite.modulate = Color("707070")


func move(to: Vector2i) -> void:
	var dx := float((to.x - grid_position.x) * Board.TILE_WIDTH)
	var dy := float((to.y - grid_position.y) * Board.TILE_HEIGHT)
	
	grid_position = to
	
	_shadow.position = Vector2(-dx, -dy)
	_sprite.position = Vector2(-dx, -dy)
	var anim_time := _ANIM_TIME_PIECE_MOVE
	var jump_y = min(_sprite.position.y - 16.0, -16.0)
	
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


func kill() -> void:
	if board != null:
		board.clear_piece(grid_position)
	board = null
	
	var move_time := _ANIM_TIME_PIECE_MOVE
	var kill_time := _ANIM_TIME_PIECE_KILL
	
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_callback(_shadow.hide) \
			.set_delay(move_time)
	tween.tween_property(_sprite, ^"modulate:a", 0.0, kill_time) \
			.set_delay(move_time)
	tween.tween_property(_sprite, ^"scale", Vector2(2.0, 2.0), kill_time) \
			.set_delay(move_time)
	tween.tween_property(_sprite, ^"rotation", randf_range(-PI, PI), kill_time) \
			.set_delay(move_time)
	tween.tween_callback(queue_free) \
			.set_delay(move_time + kill_time)


static func can_team_strike_team(striker_team: Team, victim_team: Team) -> bool:
	match striker_team:
		Team.WHITE:
			return victim_team == Team.BLACK
		Team.BLACK:
			return victim_team == Team.WHITE
	return false
