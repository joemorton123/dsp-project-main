extends AIController2D

@onready var agent: CharacterBody2D = $".."
var opponent: CharacterBody2D

var current_reward: float = 0.0
var previous_enemy_health: float = 10.0
var previous_distance: float = 1000.0

# --- THE MAGIC SYNC FLAG ---
var needs_manual_reset: bool = false 

func _ready() -> void:
	if not agent.is_agent:
		set_process(false)
		set_physics_process(false)
		return
		
	add_to_group("AGENT")
	
	# Find the opponent
	var possible_opponents = get_tree().get_nodes_in_group("player") + get_tree().get_nodes_in_group("enemy")
	for p in possible_opponents:
		if p != agent and p is CharacterBody2D:
			opponent = p
			break

func get_obs() -> Dictionary:
	if not opponent:
		return {"obs": [0.0, 0.0, 0.0, 0.0]}
		
	var distance_x = (opponent.global_position.x - agent.global_position.x) / 500.0
	var distance_y = (opponent.global_position.y - agent.global_position.y) / 500.0
	
	var my_health = agent.get_node("Health").health / 10.0
	var their_health = opponent.get_node("Health").health / 10.0
	
	return {"obs": [distance_x, distance_y, my_health, their_health]}

func get_action_space() -> Dictionary:
	return {
		"a_move": { "size": 3, "action_type": "discrete" },
		"b_attack": { "size": 3, "action_type": "discrete" },
		"c_jump": { "size": 2, "action_type": "discrete" }
	}

func set_action(action) -> void:
	if not agent.is_agent: return
	
	if needs_manual_reset:
		manual_reset()
		return 
	
	var move_choice = int(action["a_move"])
	var attack_choice = int(action["b_attack"])
	var jump_choice = int(action["c_jump"])
	
	if move_choice == 1: agent.ai_move_dir = -1.0
	elif move_choice == 2: agent.ai_move_dir = 1.0
	else: agent.ai_move_dir = 0.0
	
	agent.ai_wants_punch = (attack_choice == 1)
	agent.ai_wants_kick = (attack_choice == 2)
	agent.ai_wants_jump = (jump_choice == 1)

func get_reward() -> float:
	var step_reward: float = 0.0
	if not opponent: return 0.0
	
	var current_enemy_health = opponent.get_node("Health").health
	if current_enemy_health < previous_enemy_health:
		step_reward += 5.0 
	previous_enemy_health = current_enemy_health
	
	var current_distance = agent.global_position.distance_to(opponent.global_position)
	if current_distance < previous_distance:
		step_reward += 0.01
	elif current_distance > previous_distance:
		step_reward -= 0.01
	previous_distance = current_distance
	
	step_reward += current_reward
	current_reward = 0.0 
	return step_reward

func get_done() -> bool:
	if not opponent: return false
	var my_health = agent.get_node("Health").health
	var their_health = opponent.get_node("Health").health
	
	if my_health <= 0 or their_health <= 0:
		if their_health <= 0 and my_health > 0:
			log_win()
			
		# --- CROSS-COMMUNICATION ---
		needs_manual_reset = true
		if opponent.has_node("AIController2D"):
			opponent.get_node("AIController2D").needs_manual_reset = true
			
		return true
		
	return false

func manual_reset() -> void:
	# 1. Reset Health & Velocity
	agent.get_node("Health").health = 10
	agent.velocity = Vector2.ZERO
	
	# 2. PERFECT SYMMETRICAL SPAWNS
	# If this script is attached to the original Player node, put them on the left.
	if agent.name == "Player":
		agent.global_position = Vector2(-150, 27) 
	else:
		agent.global_position = Vector2(150, 27) 
		
	# 3. Clear Sticky Keys
	agent.ai_wants_jump = false
	agent.ai_wants_punch = false
	agent.ai_wants_kick = false
	agent.ai_move_dir = 0.0
	
	# 4. Reset the State Machine
	if agent.has_node("StateMachine/idle"):
		agent.state_machine.change_state(agent.state_machine.get_node("idle"))
		
	# 5. Reset Memory
	current_reward = 0.0
	previous_enemy_health = 10.0
	previous_distance = 1000.0
	
	# 6. Clear the flag
	needs_manual_reset = false

func log_win() -> void:
	var file_path = "res://win_tracker.txt"
	var file
	if FileAccess.file_exists(file_path):
		file = FileAccess.open(file_path, FileAccess.READ_WRITE)
		file.seek_end() 
	else:
		file = FileAccess.open(file_path, FileAccess.WRITE)
		
	if file:
		file.store_line(agent.name + " won a round!")
		file.close()

func set_heuristic(action) -> void:
	pass
