extends RefCounted

class_name PointGridSim

var points: Array[PointMassSim.PointMass]
var constraints: Array[PointMassSim.SpringConstraint]

# Original point positions
var original_positions: Array[Vector2]

# (column, row) -> Point Mass
var point_map: Dictionary[Vector2i, PointMassSim.PointMass]

var fixed_point_offset: Vector2

var gravity = Vector2(0, 0)

var grid_origin: Vector2

func get_point(row, col) -> PointMassSim.PointMass:
	return point_map[Vector2i(col, row)]

# TODO It is kinda weird that generate_point_grid is (col,row) instead of (row,col)
func generate_point_grid(point_columns: int, point_rows: int, point_distance: float):
	
	# Calculate grid origin so that point grid is centered on this node's position
	grid_origin = -Vector2(point_columns - 1, point_rows - 1) * point_distance / 2
	
	var columns = point_columns
	var rows = point_rows
	
	# Create points
	var pos = Vector2.ZERO
	for row in range(rows):
		for col in range(columns):
			var point = PointMassSim.PointMass.new(grid_origin + pos)
			
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
				
				var constraint = PointMassSim.SpringConstraint.new(point, point_b, -1, 200, 50)
				constraints.append(constraint)

func simulate(delta: float) -> void:

	# Symplectic Euler integration
	for i in range(len(points)):
		
		# Gravity
		points[i].velocity += gravity * delta
		
		if points[i].fixed:
			points[i].velocity = Vector2.ZERO
			points[i].position = grid_origin + original_positions[i] + fixed_point_offset
			continue
		
		points[i].position += points[i].velocity * delta
		
func resolve_constraints(delta: float) -> void:
	for constraint in constraints:
		constraint._resolve_constraint(delta)
