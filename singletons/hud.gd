extends CanvasLayer


enum GameOver {
	DRAW,
	FORFEIT,
	NO_MATERIAL,
}

const LEVELS := [
	{
		&"name": "Test Level",
		&"packed": preload("res://scenes/world.tscn"),
	}
]

@onready var viewport := %SubViewport
@onready var _moves_value := %Moves/Value
@onready var _turn_value := %Turn/Value
@onready var _level_value := %Level/Value
@onready var _player_turn_particles := [
	%PlayerTurnParticles0,
	%PlayerTurnParticles1,
	%PlayerTurnParticles2,
	%PlayerTurnParticles3,
]
@onready var _anim := $AnimationPlayer
@onready var _game_over_music := $GameOverMusic
@onready var _game_over_screen := %GameOverScreen
@onready var _game_over_reason_label := %GameOverReasonLabel
@onready var _game_over_retry_button := %GameOverRetryButton
@onready var _progress_loss_warning_confirm_popup = $ProgressLossWarningConfirmPopup
@onready var _settings_panel := %SettingsPanel
@onready var _middle_panel := %MiddlePanel
@onready var _forfeit_button := %ForfeitButton
@onready var _settings_button := %SettingsButton
@onready var _title_label := %TitleLabel

var current_scene: Node
var player_team: Piece.Team
var last_level_data: Dictionary
var _warned_action: Callable


func _init() -> void:
	var c := PlayerController.new()
	player_team = c.get_team()
	c.free()


func _ready() -> void:
	_settings_panel.hide()


func _on_forfeit_button_pressed() -> void:
	_warn(game_over.bind(GameOver.FORFEIT))


func _on_settings_button_pressed() -> void:
	_settings_panel.visible = not _settings_panel.visible


func _on_game_over_retry_button_pressed() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(_game_over_music, ^"volume_db", -40.0, 1.0)
	tween.tween_callback(_game_over_music.stop)
	tween.tween_property(_game_over_music, ^"volume_db", 0.0, 0.0)
	_game_over_screen.hide()
	_restart_level()


func _on_game_over_quit_button_pressed() -> void:
	_warn(_go_to_menu)


func _on_game_over_music_finished() -> void:
	var p: Vector2 = _game_over_retry_button.global_position
	
	var press := InputEventMouseButton.new()
	press.set_button_index(MOUSE_BUTTON_LEFT)
	press.set_position(p)
	press.set_pressed(true)
	
	var release := InputEventMouseButton.new()
	release.set_button_index(MOUSE_BUTTON_LEFT)
	release.set_position(p)
	release.set_pressed(false)
	
	Input.parse_input_event(press)
	Input.parse_input_event(release)


func _on_warning_cancel_button_pressed() -> void:
	_progress_loss_warning_confirm_popup.hide()


func _on_warning_confirm_button_pressed() -> void:
	_progress_loss_warning_confirm_popup.hide()
	_warned_action.call()


func _warn(unsafe_action: Callable) -> void:
	_warned_action = unsafe_action
	_progress_loss_warning_confirm_popup.popup()


func _go_to_menu() -> void:
	printerr("TODO: Hud::_go_to_menu")


func _restart_level() -> void:
	load_level(last_level_data)


func load_level(level_data: Dictionary) -> void:
	_forfeit_button.disabled = true
	_settings_button.disabled = true
	_settings_panel.visible = false
	
	if current_scene != null and current_scene is World:
		current_scene.stop_music()
	
	_anim.play(&"crossfade_in")
	await _anim.animation_finished
	
	if current_scene != null:
		current_scene.queue_free()
	
	current_scene = level_data.packed.instantiate()
	viewport.add_child(current_scene)
	last_level_data = level_data
	
	_level_value.text = level_data.name
	_title_label.text = level_data.name
	_anim.play(&"flash_title")
	await _anim.animation_finished
	_anim.play(&"crossfade_out")
	await _anim.animation_finished
	
	_forfeit_button.disabled = false
	_settings_button.disabled = false
	current_scene.get_turn_manager().next_turn()


func disable() -> void:
	current_scene.queue_free()
	current_scene = null


func report_remaining_moves(moves: int) -> void:
	_moves_value.text = str(moves)


func report_turn(team: Piece.Team, do_wipe: bool) -> void:
	match team:
		Piece.Team.WHITE:
			_turn_value.text = "WHITE"
			_turn_value.label_settings.font_color = Color.WHITE
			_turn_value.label_settings.outline_color = Color.BLACK
			_turn_value.label_settings.outline_size = 6
		
		Piece.Team.BLACK:
			_turn_value.text = "BLACK"
			_turn_value.label_settings.font_color = Color.BLACK
			_turn_value.label_settings.outline_color = Color.WHITE
			_turn_value.label_settings.outline_size = 6
		
		_:
			_turn_value.text = "NONE"
			_turn_value.label_settings.font_color = Color("b0b0b0")
			_turn_value.label_settings.outline_size = 0
	
	_player_turn_particles[0].global_position = _middle_panel.global_position + Vector2(16.0, 16.0)
	_player_turn_particles[1].global_position = _middle_panel.global_position + Vector2(-16.0, 16.0) + Vector2(_middle_panel.size.x, 0.0)
	_player_turn_particles[2].global_position = _middle_panel.global_position + Vector2(16.0, -16.0) + Vector2(0.0, _middle_panel.size.y)
	_player_turn_particles[3].global_position = _middle_panel.global_position + Vector2(-16.0, -16.0) + _middle_panel.size
	
	if team == player_team:
		for p in _player_turn_particles:
			p.emitting = true
		if do_wipe:
			_anim.play(&"player_turn_wipe", -1.0, 1.0)


func game_over(reason: GameOver) -> void:
	current_scene.stop_music()
	current_scene.get_camera_controller().set_free(false)
	
	match reason:
		GameOver.DRAW:
			_game_over_reason_label.text = "DRAW"
			_game_over_reason_label.label_settings.font_color = Color("b0b0b0")
		
		GameOver.FORFEIT:
			_game_over_reason_label.text = "FORFEIT"
			_game_over_reason_label.label_settings.font_color = Color.RED
		
		GameOver.NO_MATERIAL:
			_game_over_reason_label.text = "NO MATERIAL"
			_game_over_reason_label.label_settings.font_color = Color.RED
	
	_game_over_music.play(0.0)
	_anim.play(&"game_over_show")


func is_settings_open() -> bool:
	return _settings_panel.visible
