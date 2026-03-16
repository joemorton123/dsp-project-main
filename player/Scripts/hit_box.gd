class_name HitBox
extends Area2D


@export var damage: int = 1 : set = set_damage, get = get_damage
<<<<<<< HEAD
var attack_id: int = 0


func start_attack() -> void:
	attack_id += 1
=======
>>>>>>> dcd3ecb527f85fa55630e7d6f168040239aa5eb2


func set_damage(value: int):
	damage = value


func get_damage() -> int:
	return damage
