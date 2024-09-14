@tool
class_name StateMachine
extends Node


enum DefaultProcessor {
	PROCESS,
	PHYSICS_PROCESS,
	NONE,
}

@export var node: Node:
	set(_set_node):
		node = _set_node
		update_configuration_warnings()
@export var default_state_name: StringName = &"":
	set(_set_default_state):
		default_state_name = _set_default_state
		update_configuration_warnings()
@export var default_processor := DefaultProcessor.PROCESS

var _state_refs := {}
var _state_ref: State
var _states := {}
var _process_funcs: Array[Callable] = []
var _enter_funcs: Array[Callable] = []
var _exit_funcs: Array[Callable] = []
var _state: int


func _ready() -> void:
	set_process(not Engine.is_editor_hint())
	set_physics_process(not Engine.is_editor_hint())
	if Engine.is_editor_hint():
		return
	
	if default_state_name not in _states:
		default_state_name = _states.keys()[0]
	
	_state = _states[default_state_name]
	_state_ref = _state_refs[default_state_name]
	_enter_funcs[_state].call()


func _process(delta: float) -> void:
	if default_processor == DefaultProcessor.PROCESS:
		process(delta)


func _physics_process(delta: float) -> void:
	if default_processor == DefaultProcessor.PHYSICS_PROCESS:
		process(delta)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if node == null:
		warnings.push_back("Node mustn't be null.")
	if default_state_name.is_empty():
		warnings.push_back("default_state_name is empty, defaulting to first state in internal state registry.")
	return warnings


func register_state(state_ref: State) -> void:
	var idx := len(_states)
	
	_states[state_ref.name] = idx
	_state_refs[state_ref.name] = state_ref
	_process_funcs.push_back(func(_delta: float): pass)
	_enter_funcs.push_back(func(): pass)
	_exit_funcs.push_back(func(): pass)
	
	var pf = node.get(state_ref.process_func)
	var nf = node.get(state_ref.enter_func)
	var xf = node.get(state_ref.exit_func)
	
	if pf is Callable:
		_process_funcs[idx] = pf
	elif pf == null and not state_ref.process_func.is_empty():
		printerr("(%s) %s::%s does not exist!" % [state_ref.name, node.name, state_ref.process_func])
	
	if nf is Callable:
		_enter_funcs[idx] = nf
	elif nf == null and not state_ref.enter_func.is_empty():
		printerr("(%s) %s::%s does not exist!" % [state_ref.name, node.name, state_ref.enter_func])
	
	if xf is Callable:
		_exit_funcs[idx] = xf
	elif xf == null and not state_ref.exit_func.is_empty():
		printerr("(%s) %s::%s does not exist!" % [state_ref.name, node.name, state_ref.exit_func])


func process(delta: float) -> void:
	_process_funcs[_state].call(delta)


func switch(state_name: StringName) -> void:
	_exit_funcs[_state].call()
	_state = _states[state_name]
	_state_ref = _state_refs[state_name]
	_enter_funcs[_state].call()


func get_state_ref() -> State:
	return _state_ref
