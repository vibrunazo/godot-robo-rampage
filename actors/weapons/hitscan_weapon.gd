class_name HitscanWeapon
extends Node3D

@export var weapon_damage: float = 15
## How many times per second the weapon can shoot
@export var shoot_rate: float = 14.0
## How far to recoil in meters
@export var recoil: float = 0.05
## If true automatically fires when mouse is held down, else requires reclick each time
@export var automatic: bool = false

## The mesh that will be animated during recoil. Override on children
@export var weapon_mesh: Node3D
## Override on children to add muzzle flash emited when firing
@export var muzzle_flash: GPUParticles3D
@export var sparks: PackedScene
@export var ammo_handler: AmmoHandler
@export var ammo_type: AmmoHandler.ammo_type

@onready var ray_cast: RayCast3D = $RayCast
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var weapon_position: Vector3 = weapon_mesh.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if automatic:
		if Input.is_action_pressed("fire"):
			if cooldown_timer.is_stopped():
				shoot()
	else:
		if Input.is_action_just_pressed("fire"):
			if cooldown_timer.is_stopped():
				shoot()
	weapon_mesh.position = weapon_mesh.position.lerp(weapon_position, delta * 10)

func shoot() -> void:
	if not ammo_handler.has_ammo(ammo_type): return
	ammo_handler.use_ammo(ammo_type)
	if muzzle_flash: muzzle_flash.restart()
	cooldown_timer.start(1.0 / shoot_rate)
	#print('shootd at %s ' % [ray_cast.get_collider()])
	weapon_mesh.position.z += recoil
	var collider:  = ray_cast.get_collider()
	if not collider: return
	collider = collider.owner
	if collider is Enemy:
		collider.hitpoints -= weapon_damage
		collider.push((collider.global_position - global_position).normalized() * 200 * recoil)
	if collider:
		var spark := sparks.instantiate() as GPUParticles3D
		add_child(spark)
		spark.global_position = ray_cast.get_collision_point()
