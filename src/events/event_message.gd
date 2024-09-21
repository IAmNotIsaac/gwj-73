class_name EventMessage
extends Event


@export_multiline var message := ""


func _fire() -> void:
		Hud.message(message)
		await Hud.message_ok
