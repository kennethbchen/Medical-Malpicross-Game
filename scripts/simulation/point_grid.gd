extends Node2D

@export var draw_sim: bool = false
@export var hide_fixed: bool = true

var points: Array[PointMassSim.PointMass]
var constraints: Array[PointMassSim.SpringConstraint]

# Original point positions
var original_positions: Array[Vector2]

# (column, row) -> Point Mass
var point_map: Dictionary[Vector2i, PointMassSim.PointMass]

var fixed_point_offset: Vector2

var gravity = Vector2(10, 0)

func get_point(row, col) -> PointMassSim.PointMass:
	return point_map[Vector2i(col, row)]

# TODO It is kinda weird that generate_point_grid is (col,row) instead of (row,col)
func generate_point_grid(point_columns: int, point_rows: int, point_distance: float):
	
	var columns = point_columns
	var rows = point_rows
	
	# Create points
	var pos = Vector2.ZERO
	for row in range(rows):
		for col in range(columns):
			var point = PointMassSim.PointMass.new(pos)
			
			points.append(point)
			original_positions.append(pos)
			
			if row == 0 or row == rows - 1 or col == 0 or col == columns - 1:
				point.fixed = true
			
			point_map[Vector2i(col, row)] = point
				
			pos.x += point_distance
		
		pos.y += point_distance
		pos.x = 0
	
	# Create constraints
	for row in range(rows):
		for col in range(columns):
			var point = point_map[Vector2i(col, row)]
			
			if not point: continue
			
			for neighbor_coord in [Vector2i(col + 1, row), Vector2i(col, row + 1)]:
				var point_b = point_map.get(neighbor_coord)
				
				if not point_b: continue
				
				var constraint = PointMassSim.SpringConstraint.new(point, point_b, -1, 100, 50)
				constraints.append(constraint)

func _physics_process(delta: float) -> void:
	
	_simulate(delta)
	
	for constraint in constraints:
		constraint._resolve_constraint(delta)
		
	queue_redraw()

func _simulate(delta: float) -> void:

	# Symplectic Euler integration
	for i in range(len(points)):
		
		# Gravity
		points[i].velocity += gravity * delta
		
		if points[i].fixed:
			points[i].velocity = Vector2.ZERO
			points[i].position = original_positions[i] + fixed_point_offset
			continue
		
		points[i].position += points[i].velocity * delta

func _draw():

	if not draw_sim: return
	
	for i in range(len(constraints)):
		
		if (constraints[i].point_a.fixed or constraints[i].point_b.fixed) and hide_fixed:
			continue
		
		var color: Color = Color.WHITE
		draw_line(constraints[i].point_a.position, constraints[i].point_b.position, color, 4)
		
	for i in range(len(points)):
		
		if points[i].fixed and hide_fixed:
			continue
		
		draw_circle(points[i].position, 4, Color.LIGHT_GREEN, 5)
