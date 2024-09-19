class_name World
extends Node2D


signal cutscene_begun
signal cutscene_ended

@export var track: AudioStream

var _boards: Array[Board] = []
var _controllers: Array[Controller] = []
var _speakers: Array[Speaker] = []
var _camera_controller: CameraController
var _capture_effect: AudioEffectCapture


func _ready() -> void:
	var tl := Vector2.INF
	var br := -Vector2.INF
	for b in _boards:
		var tl_cmp := b.position
		var br_cmp := b.position + Vector2(b.size) * Vector2(Board.TILE_WIDTH, Board.TILE_HEIGHT)
		tl = tl.min(tl_cmp)
		br = br.max(br_cmp)
	_camera_controller.declare_bounds(tl, br)


func register_board(board: Board) -> void:
	if board in _boards:
		printerr("Tried to double-register board (%s)" % board)
		return
	_boards.push_back(board)


func register_controller(controller: Controller) -> void:
	if controller in _controllers:
		printerr("Tried to double-register controller (%s)" % controller)
		return
	_controllers.push_back(controller)


func register_speaker(speaker: Speaker) -> void:
	if speaker in _speakers:
		printerr("Tried to double-register speaker (%s)" % speaker)
		return
	_speakers.push_back(speaker)


func register_camera_controller(controller: CameraController) -> void:
	if _camera_controller != null:
		printerr("Overwriting previously registered camera controller (%s)" % controller)
	_camera_controller = controller


func get_boards() -> Array[Board]:
	return _boards


func get_controllers() -> Array[Controller]:
	return _controllers


func get_speakers() -> Array[Speaker]:
	return _speakers


func get_camera_controller() -> CameraController:
	return _camera_controller


func begin_cutscene() -> void:
	cutscene_begun.emit()


func end_cutscene() -> void:
	cutscene_ended.emit()
