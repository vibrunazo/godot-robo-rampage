extends Node3D

@export var weapon_1: HitscanWeapon
@export var weapon_2: HitscanWeapon

func _ready() -> void:
	equip_weapon(weapon_1)

func equip_weapon(active_weapon: HitscanWeapon) -> void:
	for child in get_children():
		if child is not HitscanWeapon: continue
		if child == active_weapon:
			child.show()
			child.set_process(true)
		else:
			child.hide()
			child.set_process(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_1"):
		equip_weapon(weapon_1)
	if event.is_action_pressed("weapon_2"):
		equip_weapon(weapon_2)
