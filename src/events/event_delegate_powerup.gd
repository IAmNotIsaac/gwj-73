class_name EventDelegatePowerup
extends EventDelegate


@export var powerup: PowerPlate


func _ready() -> void:
	handle(powerup.tree_exiting)
