@tool
class_name Speaker
extends Node2D


@export_range(0, 20000, 1, "suffix:px") var radius := 1000:
	set(v):
		radius = v
		if is_inside_tree():
			_player.max_distance = radius
		queue_redraw()
@export_exp_easing("attenuation") var attenuation := 1.0:
	set(v):
		attenuation = v
		if is_inside_tree():
			_player.attenuation = attenuation


var _world: World

@onready var _player := $AudioStreamPlayer2D
@onready var _dish := $Dish


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	if get_parent() is World:
		_world = get_parent()
		_world.register_speaker(self)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_player.max_distance = radius
	_player.attenuation = attenuation
	_player.stream = _world.track
	_player.play()
	
	_player.volume_db = -40.0
	var tween := get_tree().create_tween()
	tween.tween_property(_player, ^"volume_db", 0.0, 1.0)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var a := _get_amplitude()
	var s := clampf(a + 1.0, 1.0, 1.2 + randf() * 0.1)
	_dish.scale = Vector2.ONE * s


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	draw_circle(Vector2.ZERO, radius, Color.SEA_GREEN, false, 10.0)


func _get_amplitude() -> float:
	var db_l := AudioServer.get_bus_peak_volume_left_db(1, 0)
	var db_r := AudioServer.get_bus_peak_volume_right_db(1, 0)
	var db := (db_l + db_r) * 0.5
	return db_to_linear(db)


func stop_music() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(_player, ^"volume_db", -40.0, 1.0)
	tween.tween_callback(_player.stop)
