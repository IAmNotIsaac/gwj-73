class_name EventDelegatePowerup
extends EventDelegate


@export var powerup: PowerPlate


func _ready() -> void:
	connect_to_signal(powerup.tree_exiting)
