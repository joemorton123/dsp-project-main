class_name PlayerWalkState
extends PlayerState

const SPEED: float = 75

func enter() -> void:
	super()
	player.animation.play(walk_anim)
	
func exit(new_state: State = null) -> void:
	super(new_state)
	player.velocity.x = 0.0
	
func process_input(event: InputEvent) -> State:
	super(event)
	# This only runs for the HUMAN player!
	if event.is_action_pressed(movement_key): determine_sprite_flipped(event.as_text())
	elif event.is_action_pressed(jump_key): return jump_state
	elif event.is_action_pressed(punch_key):     return punch_state
	elif event.is_action_pressed(kick_key): return kick_state
	return null

func process_physics(delta: float) -> State:
	# 1. AI ACTION CHECKS
	if player.is_agent:
		if player.ai_wants_jump: return jump_state
		if player.ai_wants_punch: return punch_state
		if player.ai_wants_kick: return kick_state

	# 2. MOVEMENT (Declare 'direction' BEFORE i try to use it for flipping!)
	var direction = get_move_dir()
	
	# 3. AI SPRITE FLIPPING & HITBOX DIRECTION
	if player.is_agent and direction != 0.0:
		sprite_flipped = not (direction > 0)
		player.sprite.flip_h = sprite_flipped
		
	player.velocity.x = direction * SPEED
	
	var new_state = super(delta)
	if new_state: 
		return new_state
		
	if direction == 0.0:
		return idle_state
		
	return null
	
