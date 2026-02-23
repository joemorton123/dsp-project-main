class_name PlayerIdleState
extends PlayerState

func enter() -> void:
	player.animation.play(idle_anim)
	
func exit(new_state: State = null) -> void:
	super(new_state)
	
func process_input(event: InputEvent) -> State:
	super(event)
	if event.is_action_pressed(movement_key): 
		determine_sprite_flipped(event.as_text())
		return walk_state
	elif event.is_action_pressed(jump_key): return jump_state
	elif event.is_action_pressed(punch_key): return punch_state
	elif event.is_action_pressed(kick_key): return kick_state
	return null

func process_physics(delta: float) -> State:
	super(delta)
	if not player.is_agent:
		if Input.get_axis(left_key, right_key) != 0.0:
			return walk_state
	return null
