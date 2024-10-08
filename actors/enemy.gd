class_name Enemy
extends CharacterBody3D


@export var speed := 6.0
@export var speed_max := 9.0
@export var max_hitpoints: float = 100
@export var aggro_range: float = 12.0
@export var attack_range: float = 1.5
@export var weapon_damage: float = 20
@export var turn_speed: float = 10

var player: Player
var provoked: bool = false:
	set(value):
		if not provoked and value:
			provoked = value
			call_for_help()
		else:
			provoked = value
		
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
## number that is random per enemy instance used to make each enemy a little different
var rand_seed: float = randf()
## Knockback vector used to push the enemy back when shot
var knockback: Vector3

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var help_range: Area3D = $HelpRange
@onready var ray_cast: RayCast3D = $RayCast
@onready var headlight: OmniLight3D = %Headlight

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	setup_nav()
	speed = rand_rsf(speed, speed_max)
	#print('enemy %s from 10 to 15: %s, from 20 to 50: %s' % [name, rand_rsf(10, 15), rand_rsf(20, 50)])

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

## random range from seed, returns a number from and to given parameters
## that is always the same for each enemy but different between enemies.
## Inclusive.
func rand_rs(from: int, to: int) -> int:
	return roundi(rand_seed * 666) % (to - from + 1) + from
	
func rand_rsf(from: float, to: float) -> float:
	var i: float = float(roundi(rand_seed * 888 * (from + 7) * (to + 13)) % (123)) / 123.0
	#print('x: %s, y: %s' % [rand_seed, i])
	return lerpf(from, to, i)

func _physics_process(delta: float) -> void:
	next_position = navigation_agent.get_next_path_position()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if playback.get_current_node() == "attack": return
	var direction: = global_position.direction_to(next_position)
	var t := Engine.get_physics_frames()
	var s: float = sin(float(t) / rand_rsf(10, 30) + rand_rsf(0, 50))
	direction = direction.rotated(Vector3.UP, s*PI/rand_rsf(8, 20))
	distance = global_position.distance_to(player.global_position)
	if distance <= aggro_range and not provoked:
		provoked = should_I_aggro_player()
	#if provoked and Engine.get_physics_frames() % 30:
		#call_for_help()
		
	
	if direction:
		look_at_target(direction)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	velocity += knockback
	knockback = lerp(knockback, Vector3.ZERO, delta * 20)
	move_and_slide()
	try_attack()

func should_I_aggro_player() -> bool:
	return test_los_with(player)

func test_los_with(body: CharacterBody3D) -> bool:
	ray_cast.target_position = to_local(body.global_position)
	ray_cast.force_raycast_update()
	if ray_cast.get_collider() == body:
		return true
	return false

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
	#animation_player.play("attack")
	playback.travel("attack")
	
func attack() -> void:
	#print('ATTAAAAACK')
	if not player: return
	player.hitpoints -= weapon_damage
	
	
func call_for_help() -> void:
	#print('HHHALP')
	for body in help_range.get_overlapping_bodies():
		if body is Enemy:
			if test_los_with(body):
				body.receive_call_for_help()
	var tween: Tween = create_tween()
	tween.tween_property(headlight, "light_color", Color(1.2, 0.05, 0.05), 0.5)

func receive_call_for_help() -> void:
	if !provoked: 
		provoked = true
	
func push(push_vector: Vector3) -> void:
	push_vector.y *= 0.3
	knockback += push_vector

func _on_navigation_agent_3d_link_reached(details: Dictionary) -> void:
	is_linking = true
	await get_tree().create_timer(2).timeout
	is_linking = false
