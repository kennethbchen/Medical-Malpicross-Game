extends Node2D

var points: Array[PointMassSim.PointMass]
var constraints: Array[PointMassSim.SpringConstraint]

# (column, row) -> Point Mass
var point_map: Dictionary[Vector2, PointMassSim.PointMass]

var gravity: Vector2 = Vector2(0,0)

func _ready() -> void:
	
	generate_point_grid(10, 10, 40)
	"""
	var point_count: int = 20
	var length: float = 40

	var pos: = Vector2(30, 30)
	for i in range(point_count):
		points.append(PointMassSim.PointMass.new(pos))
		pos.x += length
	
	points[0].fixed = true
	points[-1].fixed = true
	
	for i in range(len(points) - 1):
		constraints.append(PointMassSim.SpringConstraint.new(points[i], points[i + 1], length, 500))
	"""

func generate_point_grid(columns: int, rows: int, point_distance: float):
	
	# Create points
	var pos = Vector2.ZERO
	for row in range(rows):
		for col in range(columns):
			points.append(PointMassSim.PointMass.new(pos))
			
			pos.x += point_distance
			print(pos)
		
		pos.y += point_distance
		pos.x = 0
	
	# Create constraints
	
	
func _get_neighbor_coords(column: int, row: int):
	return [
		Vector2(column + 1, row),
		Vector2(column - 1, row),
		Vector2(column, row + 1),
		Vector2(column, row - 1),
	]
func _physics_process(delta: float) -> void:
	
	_simulate(delta)
	
	for constraint in constraints:
		constraint._resolve_constraint(delta)
		
	queue_redraw()

func _simulate(delta: float) -> void:
	# Gravity
	for point in points:
		point.velocity += gravity * delta
	
	# Symplectic Euler integration
	for point in points:
		
		if point.fixed:
			point.velocity = Vector2.ZERO
			continue
		
		point.position += point.velocity * delta

func _draw():

	for i in range(len(constraints)):
		var color: Color = Color.WHITE
		draw_line(constraints[i].point_a.position, constraints[i].point_b.position, color, 4)
		
	for i in range(len(points)):

		draw_circle(points[i].position, 4, Color.LIGHT_GREEN, 5)
