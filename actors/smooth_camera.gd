extends Camera3D

@export var speed: float = 22.0

func _physics_process(delta: float) -> void:
	if not get_parent(): return
	var weight: float = clampf(delta * speed, 0, 1)
	global_transform = global_transform.interpolate_with(get_parent().global_transform, weight)
	global_position = get_parent().global_position
