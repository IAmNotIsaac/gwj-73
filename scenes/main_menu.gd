extends Control


signal _show_menu

@onready var _continue_button := %ContinueButton
@onready var _new_game_button := %NewGameButton
@onready var _settings_button := %SettingsButton
@onready var _credits_button := %CreditsButton
@onready var _quit_button := %QuitButton
@onready var _settings_panel := %SettingsPanel
@onready var _credits_panel := %CreditsPanel
@onready var _music := $Music
@onready var _intro_sequence := $IntroSequence
@onready var _anim := $AnimationPlayer


func _ready() -> void:
	_settings_panel.hide()
	_credits_panel.hide()
	_continue_button.visible = Progress.last_level >= 0
	_quit_button.visible = OS.get_name() != "Web"
	_start_music()
	_intro_sequence.intro0_finished.connect(_show_menu.emit)
	await _show_menu
	_anim.play(&"fade_in")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and Progress.play_count > 1:
		_show_menu.emit()
		_intro_sequence.skip_intro0()


func _on_continue_button_pressed() -> void:
	_stop_music()
	_disable_buttons()
	Hud.load_level(Progress.last_level)


func _on_new_game_button_pressed() -> void:
	_stop_music()
	_disable_buttons()
	var play_count := Progress.play_count
	Progress.delete_progress_file()
	Progress.load_from_file()
	Progress.play_count = play_count
	Hud.load_level(0)


func _on_settings_button_pressed() -> void:
	_disable_buttons()
	_settings_panel.show()


func _on_credits_button_pressed() -> void:
	_disable_buttons()
	_credits_panel.show()


func _on_quit_button_pressed() -> void:
	_disable_buttons()
	get_tree().quit()


func _on_settings_panel_hidden() -> void:
	_enable_buttons()


func _on_credits_panel_hidden() -> void:
	_enable_buttons()


func _on_credits_exit_button_pressed() -> void:
	_credits_panel.hide()


func _disable_buttons() -> void:
	_continue_button.disabled = true
	_new_game_button.disabled = true
	_settings_button.disabled = true
	_credits_button.disabled = true
	_quit_button.disabled = true


func _enable_buttons() -> void:
	_continue_button.disabled = false
	_new_game_button.disabled = false
	_settings_button.disabled = false
	_credits_button.disabled = false
	_quit_button.disabled = false


func _start_music() -> void:
	_music.volume_db = -40.0
	_music.play()
	var tween := get_tree().create_tween()
	tween.tween_property(_music, ^"volume_db", 0.0, 1.0)


func _stop_music() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(_music, ^"volume_db", -40.0, 1.0)
	tween.tween_callback(_music.stop)
	tween.tween_property(_music, ^"volume_db", 0.0, 0.0)
