class_name PlayerState
extends State

@onready var player: Player = $"../.."

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 980)

var idle_anim: String = "idle"
var walk_anim: String = "walk"
var jump_anim: String = "jump"
var fall_anim: String = "fall"
var punch_anim: String = "punch"
var kick_anim: String = "kick"
var pain_anim: String = "pain"

@export_group("States")
@export var idle_state: PlayerState
@export var walk_state: PlayerState
@export var jump_state: PlayerState
@export var fall_state: PlayerState
@export var punch_state: PlayerState
@export var kick_state: PlayerState
@export var pain_state: PlayerState

var sprite_flipped: bool = false

var movement_key: String 
var left_key: String 
var right_key: String 
var jump_key: String 
var punch_key: String 
var kick_key: String 

var left_actions: Array 
var right_actions: Array 

func _ready() -> void:
	var prefix = "p" + str(player.player_id) + "_"
	
	movement_key = prefix + "Movement"
	left_key = prefix + "Left"
	right_key = prefix + "Right"
	jump_key = prefix + "Jump"
	punch_key = prefix + "Punch"
	kick_key = prefix + "Kick"
	
	left_actions = InputMap.action_get_events(left_key).map(func(action: InputEvent) -> String: return action.as_text().get_slice(" (", 0))
	right_actions = InputMap.action_get_events(right_key).map(func(action: InputEvent) -> String: return action.as_text().get_slice(" (", 0))

func determine_sprite_flipped(event_text: String) -> void:
	if left_actions.find(event_text) != -1: sprite_flipped = true
	elif right_actions.find(event_text) != -1: sprite_flipped = false
	player.sprite.flip_h = sprite_flipped

func get_move_dir() -> float:
	# Let the AI walk!
	if player.is_agent:
		return player.ai_move_dir 
		
	# Let the human use their assigned multiplayer keys!
	if left_key and right_key:
		return Input.get_axis(left_key, right_key)
		
	return 0.0

func process_physics(delta: float) -> State:
	player.velocity.y += gravity * delta
	player.move_and_slide()
	
	if not player.is_on_floor() and player.velocity.y > 0:
		return fall_state
		
	return null
	
func exit(new_state: State = null) -> void:
	super()
	if new_state:
		new_state.sprite_flipped = sprite_flipped
