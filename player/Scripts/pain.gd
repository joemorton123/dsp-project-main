class_name PlayerPainState
extends PlayerState

const KNOCKBACK_SPEED: float = 400.0 
const FRICTION: float = 1500.0 

func enter() -> void:
	super()
	player.animation.play(pain_anim)

	var attacker: Node2D
	if player.is_agent:
		attacker = get_tree().get_first_node_in_group("player")
	else:
		attacker = get_tree().get_first_node_in_group("enemy")
		
	if attacker:
		var direction = sign(player.global_position.x - attacker.global_position.x)
		
		player.velocity.x = direction * KNOCKBACK_SPEED

		sprite_flipped = (direction > 0)
		player.sprite.flip_h = sprite_flipped

func process_physics(delta: float) -> State:
	player.velocity.x = move_toward(player.velocity.x, 0.0, FRICTION * delta)

	super(delta)
	if not player.animation.is_playing():
		return idle_state
		
	return null
