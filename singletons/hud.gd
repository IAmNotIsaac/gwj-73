extends CanvasLayer


const LEVELS := {
	&"test": {
		&"packed": preload("res://scenes/world.tscn"),
	}
}

@onready var viewport := %SubViewport
@onready var _moves_value := %Moves/Value
@onready var _turn_value := %Turn/Value
@onready var _player_turn_particles := [
	%PlayerTurnParticles0,
	%PlayerTurnParticles1,
	%PlayerTurnParticles2,
	%PlayerTurnParticles3,
]
@onready var _anim := $AnimationPlayer

var current_scene: Node
var player_team: Piece.Team


func _init() -> void:
	var c := PlayerController.new()
	player_team = c.get_team()
	c.free()


func load_level(level_data: Dictionary) -> void:
	if current_scene != null:
		current_scene.queue_free()
	
	current_scene = level_data.packed.instantiate()
	viewport.add_child(current_scene)


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
	
	if team == player_team:
		for p in _player_turn_particles:
			p.emitting = true
		if do_wipe:
			_anim.play(&"player_turn_wipe", -1.0, 3.0)
