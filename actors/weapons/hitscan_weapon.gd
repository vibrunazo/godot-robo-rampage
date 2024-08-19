extends Node3D

## How many times per second the weapon can fire
@export var fire_rate: float = 14.0


@onready var cooldown_timer: Timer = $CooldownTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("fire"):
		if cooldown_timer.is_stopped():
			cooldown_timer.start(1.0 / fire_rate)
			fire()

func fire() -> void:
	print('fired')
