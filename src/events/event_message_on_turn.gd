class_name EventMessageOnTurn
extends EventMessage


@export var on_turn := 0


func _fire() -> void:
	if controller.turn == on_turn:
		super()
