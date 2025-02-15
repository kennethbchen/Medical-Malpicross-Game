extends "res://scripts/simulation/point_grid.gd"

var drag: bool = false

@export var x_noise: Noise
@export var y_noise: Noise

@export var noise_speed: float = 15
@export var noise_amplitude: float = 128

var target_fixed_point_offset: Vector2

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_click"):
		drag = true
	elif event.is_action_released("debug_click"):
		drag = false

func _physics_process(delta: float) -> void:
	super(delta)
	
	target_fixed_point_offset = -(get_global_mouse_position() - global_position).normalized() * 45
	
	var fixed_point_noise = Vector2(x_noise.get_noise_1d(Time.get_ticks_msec() / 1000.0 * noise_speed), \
		y_noise.get_noise_1d(Time.get_ticks_msec() / 1000.0 * noise_speed 
	)) * noise_amplitude
	
	print(fixed_point_noise)
	fixed_point_offset = lerp(fixed_point_offset, target_fixed_point_offset + fixed_point_noise, 1 - exp(-20 * delta))
