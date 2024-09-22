class_name World
extends Node2D


signal cutscene_begun
signal cutscene_ended

@export var track: AudioStream

var test_mode := false
var _boards: Array[Board] = []
var _controllers: Array[Controller] = []
var _speakers: Array[Speaker] = []
var _camera_controller: CameraController
var _turn_manager: TurnManager


func _ready() -> void:
	test_mode = self == get_tree().current_scene
	
	var tl := Vector2.INF
	var br := -Vector2.INF
	for b in _boards:
		var tl_cmp := b.position
		var br_cmp := b.position + Vector2(b.size) * Vector2(Board.TILE_WIDTH, Board.TILE_HEIGHT)
		tl = tl.min(tl_cmp)
		br = br.max(br_cmp)
	_camera_controller.declare_bounds(tl, br)
	
	if test_mode:
		Hud.current_scene = self
		_turn_manager.next_turn.call_deferred()


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


func register_turn_manager(turn_manager: TurnManager) -> void:
	if _turn_manager != null:
		printerr("Overwriting previously registered turn manager (%s)" % turn_manager)
	_turn_manager = turn_manager


func get_boards() -> Array[Board]:
	return _boards


func get_controllers() -> Array[Controller]:
	return _controllers


func get_speakers() -> Array[Speaker]:
	return _speakers


func get_camera_controller() -> CameraController:
	return _camera_controller


func get_turn_manager() -> TurnManager:
	return _turn_manager


func begin_cutscene() -> void:
	cutscene_begun.emit()


func end_cutscene() -> void:
	cutscene_ended.emit()


func stop_music() -> void:
	for speaker in _speakers:
		speaker.stop_music()
