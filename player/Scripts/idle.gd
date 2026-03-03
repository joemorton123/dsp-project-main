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
	# 1. AI ACTION CHECKS (Wake up from Idle!)
	if player.is_agent:
		if player.ai_wants_jump: return jump_state
		if player.ai_wants_punch: return punch_state
		if player.ai_wants_kick: return kick_state
		
	# 2. MOVEMENT CHECK
	var direction = get_move_dir()
	
	# If the brain wants to move, transition to walk!
	if direction != 0.0:
		return walk_state

	# Apply gravity while standing still
	var new_state = super(delta)
	if new_state: 
		return new_state
		
	return null
