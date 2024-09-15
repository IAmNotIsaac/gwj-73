class_name AttackSettings
extends Node


enum DamageSortMode {
	## All entities within the area are affected at once.
	SPLASH,
	
	## A random entity within the area is affected only.
	RANDOM,
}

@export var _position := Vector2.ZERO
@export var _direction := Vector2.RIGHT
@export var _ignored: Array[Entity] = []
@export var _delta_health := 0
@export var _time := 0
## When enabled, the attack heals the affected entities instead.
@export var _heal_mode := false
@export var _damage_sort_mode := DamageSortMode.SPLASH


func get_position() -> Vector2:
	return _position


func set_position(position: Vector2) -> AttackSettings:
	_position = position
	return self


## Move position forward by `amount` based on direction.
func move_forward(amount: float) -> AttackSettings:
	_position += _direction * amount
	return self


func get_direction() -> Vector2:
	return _direction


func set_direction(direction: Vector2) -> AttackSettings:
	_direction = direction
	return self


func get_rotation() -> float:
	return _direction.angle()


## Set direction based upon rotation
func set_rotation(rotation: float) -> AttackSettings:
	_direction = Vector2.from_angle(rotation)
	return self


func rotate(amount: float) -> AttackSettings:
	return set_rotation(get_rotation() + amount)


func get_ignored() -> Array[Entity]:
	return _ignored


func ignore(entity: Entity) -> AttackSettings:
	_ignored.push_back(entity)
	return self


func get_delta_health() -> float:
	return _delta_health


func set_delta_health(delta_health: float) -> AttackSettings:
	_delta_health = delta_health
	return self


func get_time() -> float:
	return _time


func set_time(time: float) -> AttackSettings:
	_time = time
	return self


func get_heal_mode() -> bool:
	return _heal_mode


func set_heal_mode(heal_mode: bool) -> AttackSettings:
	_heal_mode = heal_mode
	return self


func get_damage_sort_mode() -> DamageSortMode:
	return _damage_sort_mode


func set_damage_sort_mode(damage_sort_mode: DamageSortMode) -> AttackSettings:
	_damage_sort_mode = damage_sort_mode
	return self
