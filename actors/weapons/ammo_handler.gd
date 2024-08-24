class_name AmmoHandler
extends Node

@export var ammo_label: Label

enum ammo_type {
	BULLET,
	SMALL_BULLET
}

var ammo_storage := {
	ammo_type.BULLET: 10,
	ammo_type.SMALL_BULLET: 60
}

var current_ammo: ammo_type

func has_ammo(type: ammo_type) -> bool:
	if not ammo_storage.has(type): return false
	return ammo_storage[type] > 0

func use_ammo(type: ammo_type) -> void:
	if not has_ammo(type): return
	ammo_storage[type] -= 1
	update_ammo_label(type)
	
func add_ammo(type: ammo_type, amount: int) -> void:
	if not ammo_storage.has(type): return
	ammo_storage[type] = maxi(ammo_storage[type] + amount, 0)
	update_ammo_label(type)
	
func update_ammo_label(type: ammo_type) -> void:
	if not ammo_label: return
	if type == current_ammo:
		ammo_label.text = str(ammo_storage[type])

func equipped(type: ammo_type) -> void:
	current_ammo = type
	update_ammo_label(type)
