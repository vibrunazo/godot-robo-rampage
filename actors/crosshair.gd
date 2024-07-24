@tool
extends Control

@export var start: float = 16
@export var end: float = 24

func _draw() -> void:
	draw_circle(Vector2.ZERO, 4, Color.DIM_GRAY)
	draw_circle(Vector2.ZERO, 3, Color.WHITE)
	
	draw_line(Vector2(start, 0), Vector2(end, 0), Color.WHITE, 2)
	draw_line(Vector2(-start, 0), Vector2(-end, 0), Color.WHITE, 2)
	draw_line(Vector2(0, start), Vector2(0, end), Color.WHITE, 2)
	draw_line(Vector2(0, -start), Vector2(0, -end), Color.WHITE, 2)
