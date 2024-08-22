class_name AmmoHandler
extends Node

enum ammo_type {
	BULLET,
	SMALL_BULLET
}

var ammo_storage := {
	ammo_type.BULLET: 10,
	ammo_type.SMALL_BULLET: 60
}

func has_ammo(type: ammo_type) -> bool:
	if not ammo_storage.has(type): return false
	return ammo_storage[type] > 0

func use_ammo(type: ammo_type) -> void:
	if not has_ammo(type): return
	ammo_storage[type] -= 1
	print(ammo_storage[type])
	
