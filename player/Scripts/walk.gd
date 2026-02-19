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
	if event.is_action_pressed(movement_key): determine_sprite_flipped(event.as_text())
	elif event.is_action_pressed(jump_key): return jump_state
	elif event.is_action_pressed(punch_key): 	return punch_state
	elif event.is_action_pressed(kick_key): return kick_state
	return null

func process_physics(delta: float) -> State:
	do_move(get_move_dir())
	if get_move_dir() == 0.0: return idle_state
	super(delta)
	return null
	
func get_move_dir() -> float: return Input.get_axis(left_key, right_key)
	
func do_move(move_dir: float) -> void:
	player.velocity.x = move_dir * SPEED
