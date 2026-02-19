extends CanvasLayer

@onready var player_bar: ProgressBar = $HealthBars/PlayerHealthBar
@onready var enemy_bar: ProgressBar = $HealthBars/EnemyHealthBar

# Variables to hold the actual health nodes
var player_health: Health
var enemy_health: Health

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("Health"):
		player_health = player.get_node("Health")
		setup_bar(player_bar, player_health)

	var enemy = get_tree().get_first_node_in_group("enemy")
	if enemy and enemy.has_node("Health"):
		enemy_health = enemy.get_node("Health")
		setup_bar(enemy_bar, enemy_health)

func setup_bar(bar: ProgressBar, health_node: Health) -> void:
	bar.max_value = health_node.max_health
	bar.value = health_node.health
	# Connect the signal directly to the bar's value property
	health_node.health_changed.connect(func(diff): update_bar(bar, health_node))

func update_bar(bar: ProgressBar, health_node: Health) -> void:
	bar.value = health_node.health
