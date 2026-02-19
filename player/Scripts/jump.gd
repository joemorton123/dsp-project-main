class_name PlayerJumpState
extends PlayerState

const AIR_SPEED: float = 75
const JUMP_FORCE: float = -500

func enter() -> void:
	super()
	player.velocity.y = JUMP_FORCE
	player.animation.play(jump_anim)
	
func exit(new_state: State = null) -> void:
	super(new_state)
	player.velocity.x = 0.0
	
func process_input(event: InputEvent) -> State:
	super(event)
	if event.is_action_pressed(movement_key): determine_sprite_flipped(event.as_text())
	if event.is_action_released(jump_key): player.velocity.y = 0
	return null

func process_physics(delta: float) -> State:
	super(delta)
	do_move(get_move_dir())
	return super(delta)
	
func get_move_dir() -> float: return Input.get_axis(left_key, right_key)
	
func do_move(move_dir: float) -> void: player.velocity.x = move_dir * AIR_SPEED
