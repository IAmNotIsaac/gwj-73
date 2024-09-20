extends Control


signal intro0_finished

@onready var _anim := $AnimationPlayer


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"intro0":
		intro0_finished.emit()
		_anim.play(&"intro1")


func skip_intro0() -> void:
	if _anim.current_animation == &"intro0":
		_anim.play(&"intro1")
