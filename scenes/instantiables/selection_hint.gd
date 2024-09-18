extends Node2D


@onready var _top_left = $TopLeft
@onready var _top_right = $TopRight
@onready var _bottom_left = $BottomLeft
@onready var _bottom_right = $BottomRight


func _ready() -> void:
	_top_left.position = Vector2(0.0, 0.0)
	_top_right.position = Vector2(Board.TILE_WIDTH - 8, 0.0)
	_bottom_left.position = Vector2(0.0, Board.TILE_HEIGHT - 8)
	_bottom_right.position = Vector2(Board.TILE_WIDTH - 8, Board.TILE_HEIGHT - 8)
