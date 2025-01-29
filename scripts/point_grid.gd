extends Node2D

var points: Array[PointMassSim.PointMass]
var constraints: Array[PointMassSim.SpringConstraint]

# Original point positions
var original_positions: Array[Vector2]

# (column, row) -> Point Mass
var point_map: Dictionary[Vector2, PointMassSim.PointMass]

var fixed_point_offset: Vector2

var drag: bool = false

func _ready() -> void:
	
	generate_point_grid(10, 10, 50)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_click"):
		drag = true
	elif event.is_action_released("debug_click"):
		drag = false

func generate_point_grid(columns: int, rows: int, point_distance: float):
	
	# Create points
	var pos = Vector2.ZERO
	for row in range(rows):
		for col in range(columns):
			var point = PointMassSim.PointMass.new(pos)
			
			points.append(point)
			original_positions.append(pos)
			
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

	fixed_point_offset.x = cos((Time.get_ticks_msec() / 1000.0)) * 250.0
	
	if drag:
		fixed_point_offset = get_global_mouse_position() - global_position

	_simulate(delta)
	
	for constraint in constraints:
		constraint._resolve_constraint(delta)
		
	queue_redraw()

func _simulate(delta: float) -> void:

	
	# Symplectic Euler integration
	for i in range(len(points)):
		
		if points[i].fixed:
			points[i].velocity = Vector2.ZERO
			points[i].position = original_positions[i] + fixed_point_offset
			continue
		
		points[i].position += points[i].velocity * delta


func _draw():

	for i in range(len(constraints)):
		var color: Color = Color.WHITE
		draw_line(constraints[i].point_a.position, constraints[i].point_b.position, color, 4)
		
	for i in range(len(points)):

		draw_circle(points[i].position, 4, Color.LIGHT_GREEN, 5)
