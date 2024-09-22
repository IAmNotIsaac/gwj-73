@tool
class_name PowerPlate
extends Node2D


@export var power := Piece.Power.POSSESS:
	set(v):
		power = v
		if is_node_ready():
			_update_sprite()
@export var grid_position: Vector2i:
	set(v):
		grid_position = v
		if is_node_ready():
			_update_position()

var _board: Board
var _audio2: AudioStreamPlayer

@onready var _sprite := $AnimatedSprite2D
@onready var _sound := $Sound


func _ready() -> void:
	if get_parent() is not Board:
		printerr("PowerPlate expects parent to be a Board")
		return
	
	_board = get_parent()
	_update_position()
	_update_sprite()
	
	_audio2 = _sound.duplicate()
	_audio2.finished.connect(_audio2.queue_free)
	_board.get_parent().add_child.call_deferred(_audio2)


func _exit_tree() -> void:
	_audio2.play()
	_board.unregister_power_plate(self)


func _update_position() -> void:
	if _board == null:
		printerr("PowerPlate not associated with a Board")
		return
	
	position = grid_position * Vector2i(Board.TILE_WIDTH, Board.TILE_HEIGHT)


func _update_sprite() -> void:
	_sprite.play(str(power))
