extends Node2D

## Essentially a wrapper for [FleshSim] for [Node2D] usage
## Handles some Node2D specific functions like how to get mouse position
## Or how to draw the sim for debugging

@export var draw_sim: bool = false
@export var hide_fixed: bool = false
@export var draw_offsets: bool = false

var sim: FleshSim

func init(puzzle: Puzzle, sim_columns: int, sim_rows: int, cell_size: float) -> void:
	
	sim = FleshSim.new()
	sim.init(puzzle, sim_columns, sim_rows, cell_size)
	
	puzzle.input_value_changed.connect(sim._on_puzzle_input_changed)

func get_point(row, col) -> PointMassSim.PointMass:
	return sim.get_point(row, col)

func _process(delta: float) -> void:

	sim.process_trauma(delta)
	sim.set_cursor_position(get_global_mouse_position() - global_position)
	
	queue_redraw()
	
func _physics_process(delta: float) -> void:
	sim.simulate(delta)
	sim.resolve_constraints(delta)

func _add_trauma(amount: float) -> void:
	sim._add_trauma(amount)

func get_cursor_position() -> Vector2:
	return get_global_mouse_position() - global_position
	
func _draw() -> void:
	
	if draw_sim:
	
		for i in range(len(sim.constraints)):
			
			if (sim.constraints[i].point_a.fixed or sim.constraints[i].point_b.fixed) and hide_fixed:
				continue
			
			var color: Color = Color.WHITE
			draw_line(sim.constraints[i].point_a.position, sim.constraints[i].point_b.position, color, 4)
			
		for i in range(len(sim.points)):
			
			if sim.points[i].fixed and hide_fixed:
				continue
			
			draw_circle(sim.points[i].position, 4, Color.LIGHT_GREEN, 5)
		
	if draw_offsets:
		draw_circle(Vector2.ZERO, 10, Color.YELLOW)
		draw_circle(sim.fixed_point_offset, 10, Color.GREEN)
		draw_circle(sim.target_fixed_point_offset, 10, Color.BLUE)
		draw_circle(sim.input_area_center, 5, Color.PURPLE)
