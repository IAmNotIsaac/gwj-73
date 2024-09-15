class_name AttackArea
extends Area2D


var delta_health := 1
var ignored: Array[Entity] = []
var time := 0.0
var heal_mode := false
var damage_sort_mode := AttackSettings.DamageSortMode.SPLASH
var _was_in_area: Array[Entity] = []
var _elapsed_one_frame := false


func _init() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	time -= delta
	if time <= 0.0 and _elapsed_one_frame:
		_affect_entities()
		queue_free()
	_elapsed_one_frame = true


func _on_body_entered(body: Node2D) -> void:
	if _can_damage(body) and body not in _was_in_area:
		_was_in_area.push_back(body)


func _can_damage(what: Node2D) -> bool:
	return (what is Entity) and (what not in ignored)


func _affect_entities() -> void:
	var entities := get_overlapping_bodies().filter(_can_damage)
	match damage_sort_mode:
		AttackSettings.DamageSortMode.SPLASH:
			for entity in entities:
				_affect_entity(entity)
		
		AttackSettings.DamageSortMode.RANDOM:
			_affect_entity(entities.pick_random())


func _affect_entity(entity: Entity) -> void:
	if heal_mode:
		entity.heal(delta_health)
	else:
		entity.damage(delta_health)
