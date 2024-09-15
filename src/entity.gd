class_name Entity
extends CharacterBody2D


@export var health := 2


func damage(amount: int) -> void:
	health -= maxi(amount, 0)
	print("entity damaged")


func heal(amount: int) -> void:
	health += mini(amount, 0)
	print("entity healed")
