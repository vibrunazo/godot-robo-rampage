extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var player: Player
var provoked: bool = false
var aggro_range: float = 12.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if provoked:
		navigation_agent.target_position = player.global_position

func _physics_process(delta: float) -> void:
	var next_position := navigation_agent.get_next_path_position()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction: = global_position.direction_to(next_position)
	var distance := global_position.distance_to(player.global_position)
	provoked = distance <= aggro_range
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
