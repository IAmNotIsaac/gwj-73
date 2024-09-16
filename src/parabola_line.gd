@tool
class_name ParabolaLine2D
extends Node2D


@export var target_position := Vector2(10, 0):
	set(v):
		target_position = v
		_update_points()
@export var amplitude := 10.0:
	set(v):
		amplitude = v
		_update_points()
@export_range(2, 100, 1, "or_greater") var detail := 10:
	set(v):
		detail = v
		_update_points()
@export var width := 1.0:
	set(v):
		width = v
		_line.width = width
@export var default_color := Color.WHITE:
	set(v):
		default_color = v
		_line.default_color = default_color
@export var texture: Texture:
	set(v):
		texture = v
		_line.texture = texture
@export var texture_mode := Line2D.LINE_TEXTURE_TILE:
	set(v):
		texture_mode = v
		_line.texture_mode = texture_mode
@export var begin_cap_mode := Line2D.LINE_CAP_NONE:
	set(v):
		begin_cap_mode = v
		_line.begin_cap_mode = begin_cap_mode
@export var end_cap_mode := Line2D.LINE_CAP_NONE:
	set(v):
		end_cap_mode = v
		_line.end_cap_mode = end_cap_mode
@export var joint_mode := Line2D.LINE_JOINT_SHARP:
	set(v):
		joint_mode = v
		_line.joint_mode = joint_mode

var _line := Line2D.new()


func _init() -> void:
	_line.width = width
	_line.default_color = default_color
	_line.texture = texture
	_line.material = material
	_line.texture_mode = texture_mode
	_line.begin_cap_mode = begin_cap_mode
	_line.end_cap_mode = end_cap_mode
	_line.joint_mode = joint_mode


func _enter_tree() -> void:
	_update_points()
	
	if _line.get_parent() == null:
		add_child(_line, false, Node.INTERNAL_MODE_BACK)


func _process(delta):
	if Engine.is_editor_hint():
		_update_points()


func _update_points() -> void:
	var p := PackedVector2Array()
	p.resize(detail)
	
	for i in detail - 1:
		var r := float(i) / float(detail - 1)
		var x := r * target_position.x
		var fx := absf(r - 0.5) * 2.0
		var y := amplitude * (fx * fx) - amplitude + float(i) / float(detail - 1) * target_position.y
		p[i] = Vector2(x, y)
	
	p[-1] = target_position
	
	_line.points = p
