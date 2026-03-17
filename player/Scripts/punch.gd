class_name PlayerPunchState
extends PlayerState

var has_attacked: bool
# Guard flag to cancel stale awaits when the state is exited early
# (e.g. player is hit during punch recovery). Without this, the await
# in _on_animation_finished completes after we've left this state and
# sets has_attacked = true, causing the next punch entry to skip instantly.
var _is_active: bool = false

@onready var hitbox: HitBox = $HitBox
@onready var collision_shape: CollisionShape2D = $HitBox/CollisionShape2D
@onready var attack_hurtbox: HurtBox = $RecoveryHurtBox

@export var recovery_time: float = 0.2
@export var hurtbox_linger_time: float = 0.25

const ACTIVE_START_FRAME: int = 1
const ACTIVE_END_FRAME: int = 2
const ATTACK_HURTBOX_END_FRAME: int = 3
const HITBOX_X_OFFSET_WINDUP: float = 20.0
const HITBOX_X_OFFSET_ACTIVE_1: float = 24.0
const HITBOX_X_OFFSET_ACTIVE_2: float = 27.0
const HITBOX_X_OFFSET_RECOVERY: float = 23.0
const HITBOX_Y_OFFSET: float = -2.0

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

	if attack_hurtbox and not attack_hurtbox.received_damage.is_connected(_on_attack_hurt):
		attack_hurtbox.received_damage.connect(_on_attack_hurt)

	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)

	# Attack hurtbox is active from frame 0 — attacker is vulnerable for the
	# entire punch animation, not just after it ends.
	if attack_hurtbox:
		attack_hurtbox.set_deferred("monitoring", true)

	if not player.sprite.frame_changed.is_connected(_on_frame_changed):
		player.sprite.frame_changed.connect(_on_frame_changed)

	player.animation.play(punch_anim)
	_update_punch_boxes(player.sprite.frame)

	if not player.animation.animation_finished.is_connected(_on_animation_finished):
		player.animation.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func _on_frame_changed() -> void:
	if player.sprite.animation != punch_anim:
		return
	_update_punch_boxes(player.sprite.frame)

func _update_punch_boxes(frame: int) -> void:
	var hitbox_active: bool = frame >= ACTIVE_START_FRAME and frame <= ACTIVE_END_FRAME
	_update_hitbox_position_for_frame(frame)
	if hitbox:
		hitbox.set_deferred("monitoring", hitbox_active)
		hitbox.set_deferred("monitorable", hitbox_active)
	# attack_hurtbox stays on throughout animation; it is only turned off
	# after the linger window in _on_animation_finished.

func _update_hitbox_position_for_frame(frame: int) -> void:
	if collision_shape == null:
		return
	var x_offset: float = HITBOX_X_OFFSET_WINDUP
	if frame == 1:
		x_offset = HITBOX_X_OFFSET_ACTIVE_1
	elif frame == 2:
		x_offset = HITBOX_X_OFFSET_ACTIVE_2
	elif frame == ATTACK_HURTBOX_END_FRAME:
		x_offset = HITBOX_X_OFFSET_RECOVERY
	collision_shape.position = Vector2(_signed_attack_offset(x_offset), HITBOX_Y_OFFSET)

func _signed_attack_offset(x_offset: float) -> float:
	var magnitude: float = absf(x_offset)
	return -magnitude if sprite_flipped else magnitude

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

func _on_attack_hurt(_damage: int) -> void:
	player.get_node("StateMachine").change_state(pain_state)

func _on_animation_finished() -> void:
	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)

	# Hurtbox lingers after the hitbox closes so a whiffed punch can be punished.
	# The linger is longer than hurtbox_linger_time was previously (0.12 -> 0.25).
	# attack_hurtbox is already on from enter(); we just wait then turn it off.
	await get_tree().create_timer(hurtbox_linger_time).timeout

	# If we were interrupted (hit during linger), _is_active is false — bail out
	# so we don't set has_attacked = true on a state we've already left.
	if not _is_active:
		return

	if attack_hurtbox:
		attack_hurtbox.set_deferred("monitoring", false)

	await get_tree().create_timer(recovery_time).timeout

	if not _is_active:
		return

	has_attacked = true

func exit(new_state: State = null) -> void:
	# Mark inactive before any deferred calls so stale awaits abort cleanly.
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

func process_input(event: InputEvent) -> State:
	super(event)
	if has_attacked:
		if event.is_action_pressed(movement_key):
			determine_sprite_flipped(event.as_text())
			return walk_state
		elif event.is_action_pressed(jump_key):
			return jump_state
	return null

func process_frame(delta: float) -> State:
	super(delta)
	if has_attacked: return idle_state
	return null
