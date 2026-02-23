class_name PlayerPainState
extends PlayerState

const KNOCKBACK_SPEED: float = 400.0
const FRICTION: float = 1500.0

var stun_timer: float = 0.0
var has_hit_wall: bool = false

@export var extra_wall_stun: float = 0.4 

func enter() -> void:
	super()
	player.animation.play(pain_anim)
	
	stun_timer = 0.0
	has_hit_wall = false
	
	var attacker: Node2D
	if player.is_agent:
		attacker = get_tree().get_first_node_in_group("player")
	else:
		attacker = get_tree().get_first_node_in_group("enemy")
		
	if attacker:
		var direction = sign(player.global_position.x - attacker.global_position.x)
		if direction == 0: 
			direction = 1 
		
		player.velocity.x = direction * KNOCKBACK_SPEED
		sprite_flipped = (direction > 0)
		player.sprite.flip_h = sprite_flipped

func process_physics(delta: float) -> State:
	player.velocity.x = move_toward(player.velocity.x, 0.0, FRICTION * delta)
	
	super(delta)
	
	if player.is_on_wall() and not has_hit_wall:
		has_hit_wall = true
		stun_timer = extra_wall_stun
		
		var bounce_dir = -1 if sprite_flipped else 1
		player.velocity.x = bounce_dir * 50

	if player.animation.is_playing():
		return null
		
	if has_hit_wall and stun_timer > 0:
		stun_timer -= delta
		return null 
		
	return idle_state
