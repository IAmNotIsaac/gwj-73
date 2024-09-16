class_name ClickArea
extends Area2D


signal clicked(index: MouseButton, click_position: Vector2)

@export_flags("Left", "Right", "Middle", "Wheel Up", "Wheel Down",
		"Wheel Left", "Wheel Right", "X Button 1", "X Button 2")
var filter_click_type := 7

var _click_in := 0


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		viewport.set_input_as_handled()
		if not event.pressed and _click_in & 1 << int(event.button_index):
			clicked.emit(event.button_index, event.position)
		_click_in &= ~(1 << int(event.button_index))
		_click_in |= int(event.is_pressed()) << int(event.button_index) & (filter_click_type << 1)
