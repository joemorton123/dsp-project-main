class_name PlayerKickState
extends PlayerState

var has_attacked: bool
<<<<<<< HEAD
# Same stale-await guard as punch.gd — see punch.gd for rationale.
var _is_active: bool = false

@onready var hitbox: HitBox = $HitBox
@onready var collision_shape: CollisionShape2D = $HitBox/CollisionShape2D
@onready var attack_hurtbox: HurtBox = $AttackHurtBox

@export var recovery_time: float = 0.1
@export var hurtbox_linger_time: float = 0.25

const KICK_HITBOX_X_OFFSET: float = 18.25
const KICK_HITBOX_Y_OFFSET: float = 9.0
const ACTIVE_START_FRAME: int = 1
const ACTIVE_END_FRAME: int = 3
const ATTACK_HURTBOX_END_FRAME: int = 4

func _ready() -> void:
	if hitbox:
		hitbox.monitoring = false
		hitbox.monitorable = false
	if attack_hurtbox:
		attack_hurtbox.monitoring = false

func enter() -> void:
	has_attacked = false
	_is_active = true

	if player.is_agent:
		_face_opponent_for_attack()

	if hitbox and collision_shape:
		hitbox.start_attack()
		collision_shape.position = Vector2(_signed_attack_offset(KICK_HITBOX_X_OFFSET), KICK_HITBOX_Y_OFFSET)

	if attack_hurtbox and not attack_hurtbox.received_damage.is_connected(_on_attack_hurt):
		attack_hurtbox.received_damage.connect(_on_attack_hurt)

	if not player.sprite.frame_changed.is_connected(_on_frame_changed):
		player.sprite.frame_changed.connect(_on_frame_changed)

	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

	# Attack hurtbox active from frame 0 — attacker is vulnerable throughout.
	if attack_hurtbox:
		attack_hurtbox.set_deferred("monitoring", true)

	player.animation.play(kick_anim)
	_update_kick_boxes(player.sprite.frame)

	if not player.animation.animation_finished.is_connected(_on_animation_finished):
		player.animation.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func _on_frame_changed() -> void:
	if player.sprite.animation != kick_anim:
		return
	_update_kick_boxes(player.sprite.frame)

func _update_kick_boxes(frame: int) -> void:
	var hitbox_active: bool = frame >= ACTIVE_START_FRAME and frame <= ACTIVE_END_FRAME
	if hitbox:
		hitbox.set_deferred("monitoring", hitbox_active)
		hitbox.set_deferred("monitorable", hitbox_active)
	# attack_hurtbox stays on throughout animation; turned off after linger.

func _on_attack_hurt(_damage: int) -> void:
	player.get_node("StateMachine").change_state(pain_state)

func _on_animation_finished() -> void:
	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)

	# Linger window — hurtbox outlasts the hitbox so a whiff is punishable.
	await get_tree().create_timer(hurtbox_linger_time).timeout

	if not _is_active:
		return

	if attack_hurtbox:
		attack_hurtbox.set_deferred("monitoring", false)

	await get_tree().create_timer(recovery_time).timeout

	if not _is_active:
		return

	has_attacked = true

func _face_opponent_for_attack() -> void:
	var opponents: Array[Node] = get_tree().get_nodes_in_group("player") + get_tree().get_nodes_in_group("enemy")
	var closest: CharacterBody2D = null
	var closest_dist: float = INF
	for p in opponents:
		if p == player or not (p is CharacterBody2D):
			continue
		var body: CharacterBody2D = p
		var d: float = absf(body.global_position.x - player.global_position.x)
		if d < closest_dist:
			closest_dist = d
			closest = body
	if closest == null:
		return
	var dx: float = closest.global_position.x - player.global_position.x
	if dx == 0:
		return
	sprite_flipped = dx < 0
	player.sprite.flip_h = sprite_flipped

func _signed_attack_offset(x_offset: float) -> float:
	var magnitude: float = absf(x_offset)
	return -magnitude if sprite_flipped else magnitude

func exit(new_state: State = null) -> void:
	_is_active = false
	super(new_state)
	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
	if attack_hurtbox:
		attack_hurtbox.set_deferred("monitoring", false)
	if player.sprite.frame_changed.is_connected(_on_frame_changed):
		player.sprite.frame_changed.disconnect(_on_frame_changed)
	if attack_hurtbox and attack_hurtbox.received_damage.is_connected(_on_attack_hurt):
		attack_hurtbox.received_damage.disconnect(_on_attack_hurt)
=======
@onready var hitbox: HitBox = $HitBox
@onready var collision_shape: CollisionShape2D = $HitBox/CollisionShape2D

@export var recovery_time: float = 0.1

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
>>>>>>> dcd3ecb527f85fa55630e7d6f168040239aa5eb2

func process_input(event: InputEvent) -> State:
	super(event)
	if has_attacked:
<<<<<<< HEAD
		if event.is_action_pressed(movement_key):
			determine_sprite_flipped(event.as_text())
			return walk_state
		elif event.is_action_pressed(jump_key):
=======
		if event.is_action_pressed(movement_key): 
			determine_sprite_flipped(event.as_text())
			return walk_state
		elif event.is_action_pressed(jump_key): 
>>>>>>> dcd3ecb527f85fa55630e7d6f168040239aa5eb2
			return jump_state
	return null

func process_frame(delta: float) -> State:
	super(delta)
	if has_attacked: return idle_state
	return null
