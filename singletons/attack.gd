extends Node


func _create_attack_area() -> Area2D:
	var area_2d := AttackArea.new()
	return area_2d


func _create_attack_shape() -> CollisionShape2D:
	var collision_shape := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	collision_shape.shape = shape
	return collision_shape


func spawn_slash(settings: AttackSettings) -> void:
	var area := _create_attack_area()
	var shape := _create_attack_shape()
	
	area.position = settings.get_position()
	area.rotation = settings.get_rotation()
	area.ignored = settings.get_ignored()
	area.delta_health = settings.get_delta_health()
	area.time = settings.get_time()
	area.heal_mode = settings.get_heal_mode()
	area.damage_sort_mode = settings.get_damage_sort_mode()
	
	add_child(area)
	area.add_child(shape)
