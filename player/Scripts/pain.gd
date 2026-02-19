class_name PlayerPainState
extends PlayerState

@onready var hurtbox: HurtBox = $HurtBox

var has_pained: bool

func enter() -> void:
	has_pained = false
	player.animation.play(pain_anim)
	
	if not player.animation.animation_finished.is_connected(_on_pain_finished):
		player.animation.animation_finished.connect(_on_pain_finished, CONNECT_ONE_SHOT)
	
	push_back()

func _on_pain_finished() -> void:
	has_pained = true

func exit(new_state: State = null) -> void:
	super(new_state)
	player.velocity.x = 0

func process_frame(delta: float) -> State:
	if has_pained: return idle_state
	return super(delta)

func process_physics(delta: float) -> State:
	# Apply friction to the knockback
	player.velocity.x = move_toward(player.velocity.x, 0, 10)
	player.move_and_slide()
	return null

func push_back() -> void:
	# Try to find the attacker's position for realistic knockback
	if hurtbox and "hitting_area" in hurtbox and hurtbox.hitting_area:
		var push_dir: Vector2 = hurtbox.hitting_area.global_position - player.global_position
		# Push away from the attacker
		player.velocity.x = -sign(push_dir.x) * 300
	else:
		# Fallback: Push backwards based on sprite facing
		var knock_dir = 1 if sprite_flipped else -1
		player.velocity.x = knock_dir * 300
