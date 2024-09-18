extends CanvasLayer


const LEVELS := {
	&"test": {
		&"packed": preload("res://scenes/world.tscn"),
	}
}

@onready var viewport := %SubViewport

var current_scene: Node


func load_level(level_data: Dictionary) -> void:
	if current_scene != null:
		current_scene.queue_free()
	
	current_scene = level_data.packed.instantiate()
	viewport.add_child(current_scene)


func disable() -> void:
	current_scene.queue_free()
	current_scene = null
