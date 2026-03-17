class_name HurtBox
extends Area2D


signal received_damage(damage: int)


@export var health: Health
@export var hit_invulnerability_time: float = 0.2
var last_attack_by_hitbox: Dictionary = {}


func _ready() -> void:
	connect("area_entered", _on_area_entered)
	# Physics process polling removed: it caused the wall multi-hit bug by
	# re-calling _try_apply_damage every frame while overlapping. The
	# area_entered signal + attack_id dedup is sufficient for single-hit
	# registration per attack instance.


func _on_area_entered(hitbox: HitBox) -> void:
	_try_apply_damage(hitbox)


func _try_apply_damage(area: Area2D) -> void:
	if health == null:
		return

	var hitbox: HitBox = area as HitBox
	if hitbox == null:
		return

	var key: int = hitbox.get_instance_id()
	var last_attack_id: int = int(last_attack_by_hitbox.get(key, -1))
	if last_attack_id == hitbox.attack_id:
		return

	last_attack_by_hitbox[key] = hitbox.attack_id
	var old_health: int = health.health
	health.health -= hitbox.get_damage()
	if health.health == old_health:
		return
	if hit_invulnerability_time > 0.0:
		health.set_temporary_immortality(hit_invulnerability_time)
	received_damage.emit(hitbox.get_damage())
	print("Damage dealt: ", hitbox.get_damage())
