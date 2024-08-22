class_name Player
extends CharacterBody3D


const SPEED = 5.0
@export var jump_height: float = 1

@export var mouse_sensitivity: float = 0.005
@export var fall_multiplier: float = 2.0
@export var max_hitpoints: float = 100

var hitpoints: float = max_hitpoints:
	set(value):
		if value < hitpoints:
			damage_anim.stop(false)
			damage_anim.play("take_damage")
		hitpoints = value
		if hitpoints <= 0 and game_over_menu:
			game_over_menu.game_over()
		print('health: %s' % [hitpoints])
		
## How much mouse has moved last frame, adjusted to how much camera should move
var mouse_motion: Vector2 = Vector2.ZERO

@onready var camera_pivot: Node3D = $CameraPivot
@onready var damage_anim: AnimationPlayer = $DamageTexture/DamageAnim
@onready var game_over_menu: GameOverMenu = $GameOverMenu

func _ready() -> void:
	#camera.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	# Add the gravity.
	if not is_on_floor():
		if velocity.y > 0:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * fall_multiplier

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		var jump_velocity: float = sqrt(jump_height * 2 * get_gravity().length())
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = -event.relative * mouse_sensitivity
	if event.is_action_pressed("ui_cancel"):
		toggle_mouse_capture()

func toggle_mouse_capture() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
func handle_camera_rotation() -> void:
	if not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: return
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x, -90, 90)
	# needs to be reset because _input is never called when mouse doesn't move, 
	# so it's never set to zero when mouse is not moving
	mouse_motion = Vector2.ZERO
