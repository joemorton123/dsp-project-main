class_name HurtBox
extends Area2D


signal received_damage(damage: int)


@export var health: Health


func _ready():
	connect("area_entered", _on_area_entered)


func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox != null and health != null:
		# Use the setter by using 'self' or just the property name
		health.health -= hitbox.get_damage() 
		received_damage.emit(hitbox.get_damage())
		print("Damage dealt: ", hitbox.get_damage())
