class_name ClickArea
extends Area2D


signal clicked(index: MouseButton, click_position: Vector2)
signal mouse_moved(mouse_position: Vector2)
signal hacky_mouse_entered
signal hacky_mouse_exited

@export_flags("Left", "Right", "Middle", "Wheel Up", "Wheel Down",
		"Wheel Left", "Wheel Right", "X Button 1", "X Button 2")
var filter_click_type := 7

var _click_in := 0
var _was_mouse_inside := false


func _unhandled_input(event: InputEvent) -> void:
	if not _mouse_inside():
		if _was_mouse_inside:
			_was_mouse_inside = false
			hacky_mouse_exited.emit()
		return
	
	elif not _was_mouse_inside:
		hacky_mouse_entered.emit()
	
	_was_mouse_inside = true
	
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
		if not event.pressed and _click_in & 1 << int(event.button_index):
			clicked.emit(event.button_index, event.position)
		_click_in &= ~(1 << int(event.button_index))
		_click_in |= int(event.is_pressed()) << int(event.button_index) & (filter_click_type << 1)
	
	elif event is InputEventMouseMotion:
		mouse_moved.emit(event.position)


func _mouse_inside() -> bool:
	var mpos := get_global_mouse_position()
	for c in get_children(true):
		if c is CollisionShape2D and c.shape != null:
			# absolutely piss
			var r: Rect2 = c.shape.get_rect()
			if r.has_point(mpos - c.global_position):
				return true
	return false
