extends Node2D

@onready var damped_spring = $DampedSpring2D

var points: Array[PointMassSim.PointMass]
var constraints: Array[PointMassSim.SpringConstraint]

# (column, row) -> Point Mass
var point_map: Dictionary[Vector2, PointMassSim.PointMass]

# Fake inertia by simulating a damped spring?
var intertia_velocity: Vector2 = Vector2(0, 0)

var init_position: Vector2
func _ready() -> void:
	
	init_position = global_position
	
	generate_point_grid(10, 10, 50)

func generate_point_grid(columns: int, rows: int, point_distance: float):
	
	# Create points
	var pos = Vector2.ZERO
	for row in range(rows):
		for col in range(columns):
			var point = PointMassSim.PointMass.new(pos)
			points.append(point)
			
			if row == 0 or row == rows - 1:
				point.fixed = true
			
			point_map[Vector2(col, row)] = point
				
			pos.x += point_distance
		
		pos.y += point_distance
		pos.x = 0
	
	# Create constraints
	for row in range(rows):
		for col in range(columns):
			var point = point_map[Vector2(col, row)]
			
			if not point: continue
			
			for neighbor_coord in [Vector2(col + 1, row), Vector2(col, row + 1)]:
				var point_b = point_map.get(neighbor_coord)
				
				if not point_b: continue
				
				var constraint = PointMassSim.SpringConstraint.new(point, point_b, -1, 100)
				constraints.append(constraint)


func _physics_process(delta: float) -> void:
	
	position.x = init_position.x + cos((Time.get_ticks_msec() / 1000.0)) * 250.0
	intertia_velocity = (damped_spring.spring_position - global_position)

	_simulate(delta)
	
	for constraint in constraints:
		constraint._resolve_constraint(delta)
		
	queue_redraw()

func _simulate(delta: float) -> void:
	# intertia_velocity
	for point in points:
		point.velocity += intertia_velocity
	
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
