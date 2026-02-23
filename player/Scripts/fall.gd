class_name PlayerFallState
extends PlayerState

const AIR_SPEED: float = 75

func enter() -> void:
	super()
	player.animation.play(fall_anim)

func exit(new_state: State = null) -> void:
	super(new_state)
	player.velocity.x = 0.0

func process_input(event: InputEvent) -> State:
	super(event)
	if event.is_action_pressed(movement_key): 
		determine_sprite_flipped(event.as_text())
	return null

func process_physics(delta: float) -> State:

	var direction = get_move_dir()
	player.velocity.x = direction * AIR_SPEED
	
	super(delta)
	
	if player.is_on_floor():
		if direction != 0.0: 
			return walk_state
		else: 
			return idle_state
			
	return null
