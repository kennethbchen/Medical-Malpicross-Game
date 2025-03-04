extends Node3D

## Essentially a wrapper for [FleshSim] for [Node3D] usage
## Handles some Node3D specific functions like how to get mouse position
## Or how to draw the sim for debugging using [DebugDraw3D]

@export var draw_sim: bool = false
@export var hide_fixed: bool = true
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
	var space_state = get_world_3d().direct_space_state
	
	if not OS.is_debug_build(): return
	
	# Draw sim
	
	var draw_scale = 0.01
	
	if draw_sim:
	
		for i in range(len(sim.constraints)):
			
			if (sim.constraints[i].point_a.fixed or sim.constraints[i].point_b.fixed) and hide_fixed:
				continue
			
			var color: Color = Color.WHITE
			var a: Vector3 = Vector3(sim.constraints[i].point_a.position.x, 0, sim.constraints[i].point_a.position.y)
			a *= draw_scale
			var b: Vector3 = Vector3(sim.constraints[i].point_b.position.x, 0, sim.constraints[i].point_b.position.y)
			b *= draw_scale
			
			DebugDraw3D.draw_line(a, b, color)
			
		for i in range(len(sim.points)):
			
			if sim.points[i].fixed and hide_fixed:
				continue
			
			var a: Vector2 = sim.points[i].position
			a *= 0.01
			DebugDraw3D.draw_sphere(Vector3(a.x, 0, a.y), 0.03, Color.LIGHT_GREEN)
			
	if draw_offsets:
		
		var y_offset = 0.4
		DebugDraw3D.draw_sphere(Vector3(0, y_offset, 0) * draw_scale, 0.02, Color.YELLOW)
		DebugDraw3D.draw_sphere(Vector3(sim.fixed_point_offset.x, y_offset, sim.fixed_point_offset.y) * draw_scale, 0.02, Color.GREEN)
		DebugDraw3D.draw_sphere(Vector3(sim.target_fixed_point_offset.x, y_offset, sim.target_fixed_point_offset.y) * draw_scale, 0.02, Color.BLUE)
		DebugDraw3D.draw_sphere(Vector3(sim.input_area_center.x, y_offset, sim.input_area_center.y) * draw_scale, 0.02, Color.PURPLE)
	
func _physics_process(delta: float) -> void:
	sim.fixed_point_offset *= 0
	sim.simulate(delta)
	sim.resolve_constraints(delta)

func _add_trauma(amount: float) -> void:
	sim._add_trauma(amount)

func set_cursor_position(pos: Vector2) -> void:
	sim.set_cursor_position(pos)
