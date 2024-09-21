class_name EventDelegateInterface
extends EventDelegate


@export var interface: BoardInterface


func _ready() -> void:
	handle(interface.unlocked)
