class_name EventDelegatePieceKilled
extends EventDelegate


@export var piece: Piece


func _ready() -> void:
	handle(piece.killed)
