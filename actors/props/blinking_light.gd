extends OmniLight3D

## Lights will blink for a random amounts of seconds between timeout_min and timeout_max
@export var timeout_min: float = 3
## Lights will blink for a random amounts of seconds between timeout_min and timeout_max
@export var timeout_max: float = 15

var ini_energy := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ini_energy = light_energy
	await get_tree().create_timer(randf_range(timeout_min, timeout_max)).timeout
	blink()

func blink() -> void:
	var tween: Tween = create_tween()
	for i in range(randi_range(1, 3)):
		tween.tween_property(self, "light_energy", ini_energy * randf_range(0, 0.3), 0.1)
		tween.tween_property(self, "light_energy", ini_energy * randf_range(0.6, 1), 0.2)
	tween.tween_property(self, "light_energy", ini_energy, 0.2)
	await get_tree().create_timer(randf_range(timeout_min, timeout_max)).timeout
	blink()
