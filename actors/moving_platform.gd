extends Node3D


@export var end_pos_node: Node3D
@export var stop_area: Area3D
@export var speed: float = 1.8
@export var start_timer: float = 2
var end_pos: Vector3
var ini_pos: Vector3
var is_dir_forward: bool = true
var is_ready: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ini_pos = global_position
	end_pos = ini_pos
	if end_pos_node:
		end_pos = end_pos_node.global_position
	await get_tree().create_timer(start_timer).timeout
	is_ready = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_ready: return
	if is_stop_area_used(): return
	if is_dir_forward:
		global_position = global_position.move_toward(end_pos, delta * speed)
		if global_position.distance_to(end_pos) <= 0.1:
			is_dir_forward = !is_dir_forward
	else:
		global_position = global_position.move_toward(ini_pos, delta * speed)
		if global_position.distance_to(ini_pos) <= 0.1:
			is_dir_forward = !is_dir_forward

func is_stop_area_used() -> bool:
	if not stop_area: return false
	var bodies := stop_area.get_overlapping_bodies()
	for body in bodies:
		if body is Player: return true
	return false
