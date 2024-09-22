@tool
class_name Background
extends Node2D


enum Type {
	SHAPES,
	SPACE,
	CROWNS,
	NONE,
}

@export var background := Type.SHAPES:
	set(v):
		background = v
		_update_background()


func _ready() -> void:
	_update_background()


func _update_background() -> void:
	for child in get_children():
		child.hide()
	
	if background != Type.NONE:
		get_child(background).show()
