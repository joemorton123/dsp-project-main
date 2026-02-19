class_name Player
extends CharacterBody2D

@onready var state_machine: StateMachine = $"StateMachine"
@onready var animation: AnimatedSprite2D = $Sprite
@onready var sprite: AnimatedSprite2D = $Sprite 

func _ready():
	state_machine.init() 
	
	# Only connect if the node actually exists
	if has_node("Health"):
		$Health.health_changed.connect(_on_health_changed)
	else:
		print("Warning: No Health node found on Player!")

func take_damage(amount: int) -> void:
	# Backup method if Health node isn't used
	print("Player took ", amount, " damage via direct call!")
	state_machine.change_state(state_machine.get_node("pain"))

func _on_health_changed(diff: int):
	if diff < 0: # Only trigger if damage was taken (negative difference)
		state_machine.change_state(state_machine.get_node("pain"))

func _process(delta): 
	state_machine.process_frame(delta)

func _physics_process(delta): 
	state_machine.process_physics(delta)

func _input(event): 
	state_machine.process_input(event)
