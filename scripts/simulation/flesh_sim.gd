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

@export var trauma_decay: float = 0.12

@export var trauma_power: float = 2

var trauma: float = 0

var target_fixed_point_offset: Vector2

var input_area_center: Vector2

func init(puzzle: Puzzle, sim_columns: int, sim_rows: int, cell_size: float) -> void:

	generate_point_grid(sim_columns, sim_rows, cell_size)
	
	# Convert from input coordinate to board coordinate
	# Then convert from board coordinate to sim coordinate (Add (1, 1))
	# Then convert from sim coordinate to position
	# Finally, add 1/2 cell size to offset from center of cell instead of top left
	# This position is the center of the input area in pixel space
	var offset = puzzle.input_to_board_coordinate((puzzle.input_size / 2) + Vector2i(1, 1)) * cell_size
	input_area_center = grid_origin + Vector2(offset.y, offset.x) + (Vector2(cell_size, cell_size) / 2)

	
	puzzle.input_value_changed.connect(_on_puzzle_input_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_click"):
		drag = true
	elif event.is_action_released("debug_click"):
		drag = false

func _process(delta: float) -> void:

	if trauma > 0:
		trauma = clamp(trauma, 0, trauma - trauma_decay * delta)

func _physics_process(delta: float) -> void:
	super(delta)

	# Higher trauma = more movement
	var trauma_influence: float = pow(trauma, trauma_power)
	
	var avoid_intensity: float = lerp(avoidance_intensity, avoidance_intensity * 2.112, trauma_influence)
	var avoidance_contribution = -( get_global_mouse_position() - input_area_center - global_position).normalized() * avoid_intensity
	
	var noi_speed: float = lerp(noise_speed, 25.0, trauma_power)
	var noi_amplitude: float = lerp(noise_amplitude, noise_amplitude * 1.752, trauma_power)
	var noise_contribution = Vector2(x_noise.get_noise_1d(Time.get_ticks_msec() / 1000.0 * noi_speed), \
		y_noise.get_noise_1d(Time.get_ticks_msec() / 1000.0 * noi_speed 
	)) * noi_amplitude
	
	target_fixed_point_offset = (avoidance_contribution * avoidance_influence) + \
				 (noise_contribution * noise_influence)

	fixed_point_offset = lerp(fixed_point_offset, target_fixed_point_offset, 1 - exp(-0.5 * delta))

func _on_puzzle_input_changed(cell: Puzzle.InputCell, row: int, col: int) -> void:
	
	# Jerk in the opposite direciton
	var jerk_direction = -fixed_point_offset.normalized()
	
	if cell.player_input == Puzzle.INPUT_TYPE.COLORED:
		
		_add_trauma(0.8)
		fixed_point_offset =  jerk_direction * 80
		
	elif cell.player_input == Puzzle.INPUT_TYPE.CROSSED:
		
		_add_trauma(0.2)
		fixed_point_offset =  jerk_direction * 20
		
func _draw() -> void:
	super()
	
	if not draw_offsets: return
	draw_circle(Vector2.ZERO, 10, Color.YELLOW)
	draw_circle(fixed_point_offset, 10, Color.GREEN)
	draw_circle(target_fixed_point_offset, 10, Color.BLUE)
	draw_circle(input_area_center, 5, Color.PURPLE)

func _add_trauma(amount: float) -> void:
	trauma += clamp(trauma + amount, 0, 1.0)
