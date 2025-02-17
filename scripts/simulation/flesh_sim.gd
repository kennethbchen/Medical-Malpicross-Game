extends "res://scripts/simulation/point_grid.gd"

var drag: bool = false

@export_group("Movement")
@export_subgroup("Avoidance")
@export_range(0.0, 1.0, 0.1) var avoidance_influence: float = 1.0
@export var avoidance_intensity: float = 32

@export_subgroup("Noise")
@export var x_noise: Noise
@export var y_noise: Noise

@export_range(0.0, 1.0, 0.1) var noise_influence: float = 1.0
@export var noise_speed: float = 15
@export var noise_amplitude: float = 164

@export_subgroup("Oscillation")
@export_range(0.0, 1.0, 0.1) var oscillation_influence: float = 1.0
@export var oscillation_amplitude: float = 64
@export var oscillation_speed: float = 2

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_click"):
		drag = true
	elif event.is_action_released("debug_click"):
		drag = false

func _physics_process(delta: float) -> void:
	super(delta)
	
	var avoidance_contribution = -(get_global_mouse_position() - global_position).normalized() * avoidance_intensity
	
	var noise_contribution = Vector2(x_noise.get_noise_1d(Time.get_ticks_msec() / 1000.0 * noise_speed), \
		y_noise.get_noise_1d(Time.get_ticks_msec() / 1000.0 * noise_speed 
	)) * noise_amplitude * noise_influence
	
	var oscillation_contribution: Vector2 = Vector2(sin(Time.get_ticks_msec() / 1000.0 * oscillation_speed) * oscillation_amplitude, 0)
	
	var target = (avoidance_contribution * avoidance_influence) + \
				 (noise_contribution * noise_influence) + \
				 (oscillation_contribution * oscillation_influence)
		
	fixed_point_offset = lerp(fixed_point_offset, target, 1 - exp(-20 * delta))
