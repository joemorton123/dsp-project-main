extends StaticBody2D

@onready var health_node: Health = $Health

func _ready() -> void:
	# Connect the health node's "died" signal to our function
	if health_node:
		health_node.health_depleted.connect(_on_health_depleted)

func _on_health_depleted() -> void:
	print("Bag Destroyed!")
	# Optional: Play a sound or spawn a particle effect here
	
	# Destroy the object
	queue_free()
	
