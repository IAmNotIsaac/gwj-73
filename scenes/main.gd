extends Node


func _ready() -> void:
	Progress.play_count += 1
	Progress.save_to_file()
	get_tree().change_scene_to_file.call_deferred("res://scenes/main_menu.tscn")
