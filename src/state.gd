@tool
class_name State
extends Node


@export var process_func: StringName = &"":
	set(_set_process_func):
		process_func = _set_process_func
		update_configuration_warnings()
@export var enter_func: StringName = &"":
	set(_set_enter_func):
		enter_func = _set_enter_func
		update_configuration_warnings()
@export var exit_func: StringName = &"":
	set(_set_exit_func):
		exit_func = _set_exit_func
		update_configuration_warnings()


func _enter_tree() -> void:
	update_configuration_warnings()
	
	if Engine.is_editor_hint():
		return
	
	get_parent().register_state(self)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if not get_parent() is StateMachine:
		warnings.push_back("Parent must be of type StateMachine.")
	else:
		var node: Node = get_parent().node
		if node != null:
			if not process_func.is_empty() and not node.has_method(process_func):
				warnings.push_back("{}::{} (process_func) is not defined.".format([node.name, process_func], "{}"))
			if not enter_func.is_empty() and not node.has_method(enter_func):
				warnings.push_back("{}::{} (enter_func) is not defined.".format([node.name, enter_func], "{}"))
			if not exit_func.is_empty() and not node.has_method(exit_func):
				warnings.push_back("{}::{} (exit_func) is not defined.".format([node.name, exit_func], "{}"))
	return warnings
