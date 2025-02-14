extends "res://scripts/simulation/point_grid.gd"

var drag: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_click"):
		drag = true
	elif event.is_action_released("debug_click"):
		drag = false

func _physics_process(delta: float) -> void:
	super(delta)
	if drag:
		fixed_point_offset = get_global_mouse_position() - global_position
