extends PanelContainer


const _MSG_REASSIGN = "Reassign"
const _MSG_REASSIGNING = "Press any key..."

var _initial_input_move_up := InputMap.action_get_events(&"move_up")[0].duplicate()
var _initial_input_move_down := InputMap.action_get_events(&"move_down")[0].duplicate()
var _initial_input_move_left := InputMap.action_get_events(&"move_left")[0].duplicate()
var _initial_input_move_right := InputMap.action_get_events(&"move_right")[0].duplicate()

@onready var _sound_master_slider := %Sound/Master/HSlider
@onready var _sound_music_slider := %Sound/Music/HSlider
@onready var _sound_effects_slider := %Sound/Effects/HSlider
@onready var _camera_speed_slider := %Camera/Speed/HSlider
@onready var _camera_pan_slider := %Camera/Pan/HSlider
@onready var _camera_control_up_button := %Camera/UpControl/ReassignButton
@onready var _camera_control_down_button := %Camera/DownControl/ReassignButton
@onready var _camera_control_left_button := %Camera/LeftControl/ReassignButton
@onready var _camera_control_right_button := %Camera/RightControl/ReassignButton

@onready var _sound_master_vh := %Sound/Master/ValueHint
@onready var _sound_music_vh := %Sound/Music/ValueHint
@onready var _sound_effects_vh := %Sound/Effects/ValueHint
@onready var _camera_speed_vh := %Camera/Speed/ValueHint
@onready var _camera_pan_vh := %Camera/Pan/ValueHint
@onready var _camera_zoom_vh := %Camera/Zoom/ValueHint
@onready var _camera_control_up_vh := %Camera/UpControl/ValueHint
@onready var _camera_control_down_vh := %Camera/DownControl/ValueHint
@onready var _camera_control_left_vh := %Camera/LeftControl/ValueHint
@onready var _camera_control_right_vh := %Camera/RightControl/ValueHint


func _on_visibility_changed() -> void:
	if visible:
		_update_all()
	if not visible and is_node_ready():
		Settings.save_to_file()


func _on_exit_button_pressed() -> void:
	hide()


func _on_sound_master_slider_value_changed(value: float) -> void:
	_sound_master_vh.text = str(int(value / _sound_master_slider.max_value * 100.0)) + "%"
	Settings.volume_master = value


func _on_sound_music_slider_value_changed(value: float) -> void:
	_sound_music_vh.text = str(int(value / _sound_music_slider.max_value * 100.0)) + "%"
	Settings.volume_bgm = value


func _on_sound_effects_slider_value_changed(value: float) -> void:
	_sound_effects_vh.text = str(int(value / _sound_effects_slider.max_value * 100.0)) + "%"
	Settings.volume_sfx = value


func _on_camera_speed_slider_value_changed(value: float) -> void:
	_camera_speed_vh.text = str(int(value / _camera_speed_slider.max_value * 100.0)) + "%"
	Settings.camera_speed = value


func _on_camera_pan_slider_value_changed(value: float) -> void:
	_camera_pan_vh.text = str(int(value / _camera_pan_slider.max_value * 100.0)) + "%"
	Settings.camera_pan_factor = value


func _on_check_button_toggled(toggled_on: bool) -> void:
	_camera_zoom_vh.text = "ON" if toggled_on else "OFF"
	Settings.camera_zoom = toggled_on


func _on_up_control_button_pressed() -> void:
	_reassign(_camera_control_up_button, _camera_control_up_vh, &"move_up")


func _on_down_control_button_pressed() -> void:
	_reassign(_camera_control_down_button, _camera_control_down_vh, &"move_down")


func _on_left_control_button_pressed() -> void:
	_reassign(_camera_control_left_button, _camera_control_left_vh, &"move_left")


func _on_right_control_button_pressed() -> void:
	_reassign(_camera_control_right_button, _camera_control_right_vh, &"move_right")


func _on_up_control_reset_button_pressed() -> void:
	var event := _initial_input_move_up.duplicate()
	var action := &"move_up"
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	_hint_action_update_text(_camera_control_up_vh, action)


func _on_down_control_reset_button_pressed() -> void:
	var event := _initial_input_move_down.duplicate()
	var action := &"move_down"
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	_hint_action_update_text(_camera_control_down_vh, action)


func _on_left_control_reset_button_pressed() -> void:
	var event := _initial_input_move_left.duplicate()
	var action := &"move_left"
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	_hint_action_update_text(_camera_control_left_vh, action)


func _on_right_control_reset_button_pressed() -> void:
	var event := _initial_input_move_right.duplicate()
	var action := &"move_right"
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	_hint_action_update_text(_camera_control_right_vh, action)


func _reassign_button_lost_focus(button: Button) -> void:
	button.text = _MSG_REASSIGN
	button.gui_input.disconnect(_reassign_button_received_input)
	button.focus_exited.disconnect(_reassign_button_lost_focus)


func _reassign_button_received_input(event: InputEvent, button: Button, hint: Label, action: StringName) -> void:
	if event is not InputEventKey:
		return
	
	button.release_focus()
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	_hint_action_update_text(hint, action)


func _reassign(button: Button, hint: Label, action: StringName) -> void:
	button.text = _MSG_REASSIGNING
	button.gui_input.connect(_reassign_button_received_input.bind(button, hint, action))
	button.focus_exited.connect(_reassign_button_lost_focus.bind(button))


func _hint_action_update_text(hint: Label, action: StringName) -> void:
	var event := InputMap.action_get_events(action)[0]
	hint.text = event.as_text()


func _update_all() -> void:
	_sound_master_slider.value = Settings.volume_master
	_sound_music_slider.value = Settings.volume_bgm
	_sound_effects_slider.value = Settings.volume_sfx
	_camera_speed_slider.value = Settings.camera_speed
	_camera_pan_slider.value = Settings.camera_pan_factor
	_on_sound_master_slider_value_changed(_sound_master_slider.value)
	_on_sound_music_slider_value_changed(_sound_music_slider.value)
	_on_sound_effects_slider_value_changed(_sound_effects_slider.value)
	_on_camera_speed_slider_value_changed(_camera_speed_slider.value)
	_on_camera_pan_slider_value_changed(_camera_pan_slider.value)
	_hint_action_update_text(_camera_control_up_vh, &"move_up")
	_hint_action_update_text(_camera_control_down_vh, &"move_down")
	_hint_action_update_text(_camera_control_left_vh, &"move_left")
	_hint_action_update_text(_camera_control_right_vh, &"move_right")
