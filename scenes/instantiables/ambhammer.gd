extends Node2D


@onready var _particles := $CPUParticles2D
@onready var _break_sound := $BreakSound


func _ready() -> void:
	_particles.emitting = true
	await _break_sound.finished
	queue_free()
