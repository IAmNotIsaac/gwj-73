class_name CameraController
extends Node


const _CAMERA_SPEED := 500.0
const _PAN_FACTOR := 25.0

@export var camera: Camera2D

var _camera_position := Vector2.ZERO
var _camera_zoom := 1.0
var _camera_free := true
var _follow_node: Node


func _ready() -> void:
	if camera == null:
		printerr("(%s) was not assigned a camera!" % self)
		return
	
	_camera_position = camera.position


func _process(delta: float) -> void:
	if camera != null:
		var d := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down") * int(_camera_free)
		_camera_position += d * delta * _CAMERA_SPEED
		var mp := get_viewport().get_mouse_position() / get_viewport().get_visible_rect().size
		mp = mp.clamp(Vector2.ZERO, Vector2.ONE)
		mp = (mp - Vector2(0.5, 0.5)) * 2.0;
		var pan := mp * _PAN_FACTOR
		_camera_position = _follow_node.global_position if _follow_node != null else _camera_position
		camera.position = _camera_position + pan
		camera.zoom = camera.zoom.lerp(Vector2.ONE * _camera_zoom, 0.25)


func settings(position: Vector2, zoom: float, free: bool) -> void:
	_camera_position = position
	_camera_zoom = zoom
	_camera_free = free


func set_position(position: Vector2) -> void:
	_camera_position = position


func set_zoom(zoom: float) -> void:
	_camera_zoom = zoom


func set_free(free: bool) -> void:
	_camera_free = free


func reset_zoom() -> void:
	_camera_zoom = 1.0


func follow(node: Node2D) -> void:
	_follow_node = node


func stop_follow() -> void:
	_follow_node = null
