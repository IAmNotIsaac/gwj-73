@tool
class_name Background
extends Node2D


enum Type {
	SHAPES,
	SPACE,
	NONE,
}

@export var background := Type.SHAPES:
	set(v):
		background = v
		_update_background()


@onready var _shapes := $Shapes
@onready var _space := $Space


func _update_background() -> void:
	for child in get_children():
		child.hide()
	
	if background != Type.NONE:
		get_child(background).show()
