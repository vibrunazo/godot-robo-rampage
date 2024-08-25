class_name Enemy
extends CharacterBody3D


const JUMP_VELOCITY = 4.5

@export var speed := 8.0
@export var max_hitpoints: float = 100
@export var aggro_range: float = 12.0
@export var attack_range: float = 1.5
@export var weapon_damage: float = 20
@export var turn_speed: float = 10

var player: Player
var provoked: bool = false
var next_position: Vector3
var distance: float
var hitpoints: float = max_hitpoints:
	set(value):
		hitpoints = value
		if hitpoints <= 0:
			queue_free()
		provoked = true
## if true the nav agent reached a nav link and should stop updating path for a while
var is_linking: bool = false

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	setup_nav()
	animation_player.play("idle") # was not resetting after level restart
	

#func _process(delta: float) -> void:
	#print(animation_player.current_animation)
	#if provoked:
	#navigation_agent.target_position = player.global_position

func setup_nav() -> void:
	var nav_timer: Timer = Timer.new()
	nav_timer.one_shot = false
	nav_timer.timeout.connect(update_path)
	add_child(nav_timer)
	nav_timer.start(0.25)

func update_path() -> void:
	if is_linking: return
	if provoked:
		navigation_agent.target_position = player.global_position

func _physics_process(delta: float) -> void:
	next_position = navigation_agent.get_next_path_position()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction: = global_position.direction_to(next_position)
	distance = global_position.distance_to(player.global_position)
	provoked = distance <= aggro_range or provoked
	
	if direction:
		look_at_target(direction)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	try_attack()

func look_at_target(direction: Vector3) -> void :
	if global_position != next_position:
		var look_target := next_position
		look_target.y = global_position.y
		if global_position.distance_squared_to(look_target) > 0.2:
			var tr_target := transform.looking_at(look_target, Vector3.UP, true)
			basis = basis.slerp(tr_target.basis, turn_speed * get_physics_process_delta_time())
			
func try_attack() -> void:
	if not provoked: return
	if distance > attack_range: return
	play_attack()

func play_attack() -> void:
	animation_player.play("attack")
	
func attack() -> void:
	print('ATTAAAAACK')
	if not player: return
	player.hitpoints -= weapon_damage
	

func _on_navigation_agent_3d_link_reached(details: Dictionary) -> void:
	is_linking = true
	await get_tree().create_timer(2).timeout
	is_linking = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("idle")
