extends "res://scripts/simulation/point_grid.gd"

var drag: bool = false

@export var draw_offsets: bool = false

@export_group("Movement Normal")

@export_subgroup("Avoidance")
@export_range(0.0, 1.0, 0.1) var avoidance_influence: float = 1.0
@export var avoidance_intensity: float = 32

@export_subgroup("Noise")
@export var x_noise: Noise
@export var y_noise: Noise

@export_range(0.0, 1.0, 0.1) var noise_influence: float = 1.0
@export var noise_speed: float = 15
@export var noise_amplitude: float = 164

@export_group("Trauma")
# https://kidscancode.org/godot_recipes/3.x/2d/screen_shake/index.html
# https://www.youtube.com/watch?v=tu-Qe66AvtY

@export var trauma_decay: float = 0.1

@export var trauma_power: float = 2

var trauma: float = 0
var min_trauma: float = 0

var shock_direction: float = 1.0

var target_fixed_point_offset: Vector2

var input_size: Vector2i

func init(puzzle: Puzzle, sim_columns: int, sim_rows: int, cell_size: float) -> void:
	
	input_size = puzzle.input_size
	
	generate_point_grid(sim_columns, sim_rows, cell_size)
	puzzle.input_value_changed.connect(_on_puzzle_input_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_click"):
		drag = true
	elif event.is_action_released("debug_click"):
		drag = false

func _process(delta: float) -> void:

	if trauma > min_trauma:
		trauma = clamp(trauma, min_trauma, trauma - trauma_decay * delta)

func _physics_process(delta: float) -> void:
	super(delta)
	
	var trauma_influence: float = pow(trauma, trauma_power)
	
	var avoid_intensity: float = lerp(avoidance_intensity, avoidance_intensity * 3.112, trauma_influence)
	var avoidance_contribution = -(get_global_mouse_position() - global_position).normalized() * avoid_intensity
	
	var noi_speed: float = lerp(noise_speed, 10.0, trauma_power)
	var noi_amplitude: float = lerp(noise_amplitude, noise_amplitude * 1.252, trauma_power)
	
	var noise_contribution = Vector2(x_noise.get_noise_1d(Time.get_ticks_msec() / 1000.0 * noi_speed), \
		y_noise.get_noise_1d(Time.get_ticks_msec() / 1000.0 * noi_speed 
	)) * noi_amplitude
	
	target_fixed_point_offset = (avoidance_contribution * avoidance_influence) + \
				 (noise_contribution * noise_influence)

	
	fixed_point_offset = lerp(fixed_point_offset, target_fixed_point_offset, 1 - exp(-0.5 * delta))

func _on_puzzle_input_changed(cell: Puzzle.InputCell, row: int, col: int) -> void:
	if cell.player_input == Puzzle.INPUT_TYPE.COLORED:
		trauma = clamp(trauma + 0.8, min_trauma, 1.0)
		
		# Jerk in the opposite direciton 
		fixed_point_offset = -fixed_point_offset.normalized() * 80

func _draw() -> void:
	super()
	
	if not draw_offsets: return
	draw_circle(fixed_point_offset, 10, Color.GREEN)
	draw_circle(target_fixed_point_offset, 10, Color.BLUE)
