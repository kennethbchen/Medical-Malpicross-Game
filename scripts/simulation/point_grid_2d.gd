extends Node2D

@export var draw_sim: bool = false
@export var hide_fixed: bool = true

var sim: PointGridSim

func _init() -> void:
	sim = PointGridSim.new()

func init_sim(point_columns: int, point_rows: int, point_distance: float) -> void:
	sim.generate_point_grid(point_columns, point_rows, point_distance)

func _process(delta: float) -> void:
	queue_redraw()

func _physics_process(delta: float) -> void:
	sim.simulate(delta)
	sim.resolve_constraints(delta)

func _draw():
	if not draw_sim: return

	for i in range(len(sim.constraints)):
		
		if (sim.constraints[i].point_a.fixed or sim.constraints[i].point_b.fixed) and hide_fixed:
			continue
		
		var color: Color = Color.WHITE
		draw_line(sim.constraints[i].point_a.position, sim.constraints[i].point_b.position, color, 4)
		
	for i in range(len(sim.points)):
		
		if sim.points[i].fixed and hide_fixed:
			continue
		
		draw_circle(sim.points[i].position, 4, Color.LIGHT_GREEN, 5)

func get_point(row, col) -> PointMassSim.PointMass:
	return sim.point_map[Vector2i(col, row)]
