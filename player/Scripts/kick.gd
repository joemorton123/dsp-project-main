class_name PlayerKickState
extends PlayerState

var has_attacked: bool
@onready var hitbox: HitBox = $HitBox
@onready var collision_shape: CollisionShape2D = $HitBox/CollisionShape2D

@export var recovery_time: float = 0.4

func _ready() -> void:
	if hitbox:
		hitbox.monitorable = false

func enter() -> void:
	has_attacked = false
	
	if hitbox and collision_shape:
		if sprite_flipped:
			collision_shape.position.x = -16.25
		else:
			collision_shape.position.x = 18.25
			
		hitbox.set_deferred("monitorable", true)
		
	player.animation.play(kick_anim)
	
	if not player.animation.animation_finished.is_connected(_on_animation_finished):
		player.animation.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func _on_animation_finished() -> void:
	if hitbox:
		hitbox.set_deferred("monitorable", false)
		
	await get_tree().create_timer(recovery_time).timeout
	
	has_attacked = true

func exit(new_state: State = null) -> void:
	super(new_state)
	if hitbox:
		hitbox.set_deferred("monitorable", false)

func process_input(event: InputEvent) -> State:
	super(event)
	if has_attacked:
		if event.is_action_pressed(movement_key): 
			determine_sprite_flipped(event.as_text())
			return walk_state
		elif event.is_action_pressed(jump_key): 
			return jump_state
	return null

func process_frame(delta: float) -> State:
	super(delta)
	if has_attacked: return idle_state
	return null
