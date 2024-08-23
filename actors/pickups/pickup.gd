extends Area3D

## type of ammo you get when picking up
@export var ammo_type: AmmoHandler.ammo_type
## amount of ammo you get when you pick up
@export var amount: int = 20


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.pickup_ammo(ammo_type, amount)
		queue_free()
