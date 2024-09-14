extends CharacterBody2D


const _SPEED := 100.0

@onready var sm: StateMachine = $StateMachine


func get_input_move() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


func _proc_idle(_delta: float) -> void:
	if get_input_move():
		sm.switch(&"Run")


func _proc_run(_delta: float) -> void:
	velocity = get_input_move() * _SPEED
	move_and_slide()
	
	if velocity == Vector2.ZERO:
		sm.switch(&"Idle")
