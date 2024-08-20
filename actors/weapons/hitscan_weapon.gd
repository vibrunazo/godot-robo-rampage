extends Node3D

## How many times per second the weapon can shoot
@export var shoot_rate: float = 14.0
## How far to recoil in meters
@export var recoil: float = 0.05
## The mesh that will be animated during recoil
@export var weapon_mesh: Node3D

@onready var ray_cast: RayCast3D = $RayCast
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var weapon_position: Vector3 = weapon_mesh.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("fire"):
		if cooldown_timer.is_stopped():
			shoot()
	weapon_mesh.position = weapon_mesh.position.lerp(weapon_position, delta * 10)

func shoot() -> void:
	cooldown_timer.start(1.0 / shoot_rate)
	print('shootd at %s ' % [ray_cast.get_collider()])
	weapon_mesh.position.z += recoil
