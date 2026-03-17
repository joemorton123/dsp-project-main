class_name HitBox
extends Area2D


@export var damage: int = 1 : set = set_damage, get = get_damage
var attack_id: int = 0


func start_attack() -> void:
	attack_id += 1


func set_damage(value: int):
	damage = value


func get_damage() -> int:
	return damage
