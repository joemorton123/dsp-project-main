class_name HealthBar
extends ProgressBar

@export var health_node: Health

func _ready() -> void:
	if health_node:
		max_value = health_node.max_health
		value = health_node.health
		
		health_node.health_changed.connect(_on_health_changed)
		health_node.max_health_changed.connect(_on_max_health_changed)

func _on_health_changed(diff: int) -> void:
	value = health_node.health

func _on_max_health_changed(diff: int) -> void:
	max_value = health_node.max_health
