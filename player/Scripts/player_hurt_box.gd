class_name PlayerHurtBox
extends HurtBox

@onready var pain_state: PlayerPainState = $".."
@onready var state_machine: StateMachine = $"../.."

var hitting_area: Node2D

func _on_area_entered(hit_box: HitBox) -> void:
<<<<<<< HEAD
	if hit_box == null:
		return

	# Let HurtBox handle health deduction and attack_id dedup first.
	# If health didn't actually change (immortality or duplicate hit),
	# received_damage will not emit and we should not change state either.
	# We detect this by checking whether super() results in a real hit
	# by listening for the signal emission synchronously via a flag.
	var damage_was_dealt: bool = false
	var _check := func(_d: int) -> void: damage_was_dealt = true
	received_damage.connect(_check, CONNECT_ONE_SHOT)
	super(hit_box)
	# If the signal didn't fire (dedup blocked it), disconnect the one-shot
	# manually in case it hasn't fired yet (Godot won't auto-remove it).
	if received_damage.is_connected(_check):
		received_damage.disconnect(_check)

	if not damage_was_dealt:
		return

	hitting_area = hit_box

	# Only transition to pain if not already in pain. Without this guard,
	# wall contact re-fires area_entered and resets stun_timer + knockback
	# every frame, causing the multi-instance damage feel and race condition.
	if state_machine.current_state == pain_state:
		return

	state_machine.change_state(pain_state)
=======
	if hit_box == null: return
	super(hit_box)
	hitting_area = hit_box
	state_machine.change_state(pain_state)
	
>>>>>>> dcd3ecb527f85fa55630e7d6f168040239aa5eb2
