extends Entity


const _INPUT_ACTION_PRIMARY := 0b10
const _INPUT_ACTION_ALTERNATE := 0b01
const _SPEED := 100.0

var _direction := Vector2.RIGHT

@onready var sm: StateMachine = $StateMachine


func _ready() -> void:
	get_window().grab_focus()


func get_input_move() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


## Returns 2-bit binary, where:
## 0bX_ = Primary action
## 0b_X = Alternate action
func get_input_action() -> int:
	return (int(Input.is_action_just_pressed(&"primary")) << 1 |
			int(Input.is_action_just_pressed(&"alternate")) )


func _proc_idle(_delta: float) -> void:
	if get_input_move():
		sm.switch(&"Run")
	
	if get_input_action() & _INPUT_ACTION_PRIMARY:
		var settings = AttackSettings.new().set_position(position).set_direction(_direction).move_forward(0.0)
		Attack.spawn_slash(settings)


func _proc_run(_delta: float) -> void:
	velocity = get_input_move() * _SPEED
	move_and_slide()
	
	if velocity != Vector2.ZERO:
		_direction = velocity.normalized()
	
	if get_input_action() & _INPUT_ACTION_PRIMARY:
		var settings = AttackSettings.new().set_position(position).set_direction(_direction).move_forward(0.0)
		Attack.spawn_slash(settings)
	
	if velocity == Vector2.ZERO:
		sm.switch(&"Idle")
