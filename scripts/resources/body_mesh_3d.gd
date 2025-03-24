extends MeshInstance3D

class_name BodyMesh3D

@export var temp_outer_mat: StandardMaterial3D
@export var temp_inner_mat: StandardMaterial3D

var flexible_cells_margin_rows: int = 2
var flexible_cells_margin_columns: int = 2

var margin_cell_column_size: float = 0.75
var margin_cell_row_size: float = 0.75

var flexible_rows: int
var flexible_columns: int

var origin_position_offset: Vector3

# NOTE: This is confusing because sometimes we need to think about coordinates
# in terms of puzzle cell row / column
# and sometimes in terms of the rows / columns of the points that make up the cells

# Body cell space
# (x, y) / (column, row)
var flexible_cell_area_bounds: Rect2

# Body point space
# (x, y) / (column, row)
var flexible_point_area_bounds: Rect2

# Body cell space
# (x, y) / (columns, rows)
var total_grid_size: Vector2i

# Body point space
# (x, y) / (columns, rows)
var total_point_grid_size : Vector2i

var cell_size = 0

var flexible_vertices: Array[Vector3]
var cell_visibility_mask: Array[bool]

func init(input_rows: int, input_columns: int, cell_size: float) -> void:
	

	self.flexible_rows = input_rows
	self.flexible_columns = input_columns
	self.cell_size = cell_size
	
	self.flexible_cell_area_bounds = Rect2(flexible_cells_margin_columns, flexible_cells_margin_rows, input_columns, input_rows)
	
	self.flexible_point_area_bounds = Rect2(flexible_cells_margin_columns, flexible_cells_margin_rows, input_columns + 1, input_rows + 1)
	
	self.total_grid_size = Vector2i(input_columns + flexible_cells_margin_columns * 2, input_rows + flexible_cells_margin_rows * 2)
	
	# Count fenceposts instead of fence segments
	self.total_point_grid_size = total_grid_size + Vector2i(1, 1)
	
	# Calculate offset so that mesh is generated such that
	# The center of the input area is at the origin
	self.origin_position_offset = -Vector3((total_grid_size.x * cell_size) / 2.0, 0, (total_grid_size.y * cell_size) / 2.0)
	
	mesh = ArrayMesh.new()

func _get_height_bias(row, col) -> Vector3:
	
	# Modify height to give body mesh curvature
	# Based on coordinate
	var x_coord_center = (flexible_columns + flexible_cells_margin_columns * 2) / 2.0
	var x_diff = abs(pow(x_coord_center - col, 2) * 0.05)
	
	return Vector3(0, -x_diff, 0)
	
func _get_init_vertex_position(row, col, skip_height_offset: bool = false) -> Vector3:
	var new_vert: Vector3 = origin_position_offset + Vector3(col, 0, row) * cell_size
			
	# Margins have different size
	if row < flexible_cells_margin_rows:
		new_vert.z += -margin_cell_row_size * (flexible_cells_margin_rows - row)
		
	if row > flexible_cells_margin_rows + flexible_rows:
		# NOTE: Might not be the right multiplier calculation
		new_vert.z += margin_cell_row_size * (flexible_cells_margin_rows - (total_point_grid_size.y - row) + 1)
	
	if col < flexible_cells_margin_columns:
		new_vert.x += -margin_cell_column_size * (flexible_cells_margin_columns - col)

	if col > flexible_cells_margin_columns + flexible_columns:
		# NOTE: Might not be the right multiplier calculation
		new_vert.x += margin_cell_column_size * (flexible_cells_margin_columns - (total_point_grid_size.x - col) + 1)
		
	if skip_height_offset:
		return new_vert
	
	new_vert += _get_height_bias(row, col)
	
	return new_vert
	

func _point_coord_to_flexible_point_index(row, col) -> int:
	# Convert from grid row / col to flexible row / col by subtracting margin dimensions
	# Then convert from flexible row / col to flexible_vertices index by multiplying row by flexible columns + 1 and adding columns
	# We add 1 to flexible columns to convert from cell space to point space (fencepost error)
	return col - flexible_cells_margin_columns + ( (row - flexible_cells_margin_rows) * (flexible_columns + 1))

func _point_coord_to_flexible_mask_index(row, col) -> int:
	
	return col - flexible_cells_margin_columns + ( (row - flexible_cells_margin_rows) * (flexible_columns))

func _process(delta: float) -> void:
	
	if cell_size <= 0: 
		# Not initalized yet
		return
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Generate mesh one cell at a time
	# (row, col) represents the top left vertex of the cell we are currently looking at
	for row in total_point_grid_size.y - 1:
		for col in total_point_grid_size.x - 1:
			
			
			var is_flexible_cell: bool = flexible_cell_area_bounds.has_point(Vector2i(col, row))
			var generate_outer: bool = true
			
			if is_flexible_cell:
				
				# Convert from point grid space to flexible cell space by subtracting margin sizes
				var mask_index: int = col - flexible_cells_margin_columns + ( (row - flexible_cells_margin_rows) * (flexible_columns))
				
				# Flexible cell might be missing
				generate_outer = cell_visibility_mask[mask_index]
			
			var upper_back_left: Vector3 = _get_init_vertex_position(row, col)
			var upper_back_right: Vector3 = _get_init_vertex_position(row, col + 1)
			var upper_front_left: Vector3 = _get_init_vertex_position(row + 1, col)
			var upper_front_right: Vector3 = _get_init_vertex_position(row + 1, col + 1)
			
			# Sample relevant vertices from flexible_vertices if needed
			if flexible_point_area_bounds.has_point(Vector2i(col, row)):
				upper_back_left = flexible_vertices[_point_coord_to_flexible_point_index(row, col)]
				upper_back_left += _get_height_bias(row, col)
			
			if flexible_point_area_bounds.has_point(Vector2i(col + 1, row)):
				upper_back_right = flexible_vertices[_point_coord_to_flexible_point_index(row, col + 1)]
				upper_back_right += _get_height_bias(row, col + 1)
			
			if flexible_point_area_bounds.has_point(Vector2i(col, row + 1)):
				upper_front_left = flexible_vertices[_point_coord_to_flexible_point_index(row + 1, col)]
				upper_front_left += _get_height_bias(row + 1, col)
			
			if flexible_point_area_bounds.has_point(Vector2i(col + 1, row + 1)):
				upper_front_right = flexible_vertices[_point_coord_to_flexible_point_index(row + 1, col + 1)]
				upper_front_right += _get_height_bias(row + 1, col + 1)
			
			if generate_outer:
				var ind = col + (total_point_grid_size.x) * row
				
				# TODO: Because the cell sizes are variable on the margins,
				# we can't calculate the UVs correctly only based on row / col
				# we need to use real coordinate space positions
				
				st.set_material(temp_outer_mat)
				# Tri 1
				st.set_uv(Vector2(col, row) / (Vector2(total_point_grid_size) - Vector2(1, 1)))
				st.add_vertex(upper_back_left)
				
				st.set_uv(Vector2(col + 1, row) / (Vector2(total_point_grid_size) - Vector2(1, 1)))
				st.add_vertex(upper_back_right)
				
				st.set_uv(Vector2(col, row + 1) / (Vector2(total_point_grid_size) - Vector2(1, 1)))
				st.add_vertex(upper_front_left)
				
				# Tri 2
				st.set_uv(Vector2(col + 1, row) / (Vector2(total_point_grid_size) - Vector2(1, 1)))
				st.add_vertex(upper_back_right)
				
				st.set_uv(Vector2(col + 1, row + 1) / (Vector2(total_point_grid_size) - Vector2(1, 1)))
				st.add_vertex(upper_front_right)
				
				st.set_uv(Vector2(col, row + 1) / (Vector2(total_point_grid_size) - Vector2(1, 1)))
				st.add_vertex(upper_front_left)
			elif is_flexible_cell and not generate_outer:
				# Generate inner body instead
				
				var body_depth_offset: Vector3 = Vector3(0, -1, 0)
				
				# Vertices on the cube (so, 8 vertices) that this cell represents
				
				# Floor vertices. We can calculate these as new based on row / col
				var lower_back_left: Vector3 = _get_init_vertex_position(row, col, true) + body_depth_offset
				var lower_back_right: Vector3 = _get_init_vertex_position(row, col + 1, true) + body_depth_offset
				var lower_front_left: Vector3 = _get_init_vertex_position(row + 1, col, true) + body_depth_offset
				var lower_front_right: Vector3 = _get_init_vertex_position(row + 1, col + 1, true) + body_depth_offset

				# TODO: seems like we need a separate surface tool if we want multiple materials
				st.set_material(temp_inner_mat)
				
				# Floor tris
				st.add_vertex(lower_back_left)
				st.add_vertex(lower_back_right)
				st.add_vertex(lower_front_left)
				
				st.add_vertex(lower_back_right)
				st.add_vertex(lower_front_right)
				st.add_vertex(lower_front_left)
				
				# Wall tris
				# Check if each wall needs to be made
				# Doesn't need to be made if it neighbors another hole
				
				# Back wall
				
				if row - flexible_cells_margin_rows == 0 or cell_visibility_mask[_point_coord_to_flexible_mask_index(row - 1, col)]: 
					st.add_vertex(upper_back_left)
					st.add_vertex(upper_back_right)
					st.add_vertex(lower_back_left)
					
					st.add_vertex(upper_back_right)
					st.add_vertex(lower_back_right)
					st.add_vertex(lower_back_left)
				
				# Left Wall
				if col - flexible_cells_margin_columns == 0 or cell_visibility_mask[_point_coord_to_flexible_mask_index(row, col - 1)]: 
					st.add_vertex(upper_front_left)
					st.add_vertex(upper_back_left)
					st.add_vertex(lower_front_left)
				
					st.add_vertex(upper_back_left)
					st.add_vertex(lower_back_left)
					st.add_vertex(lower_front_left)
				
				# Right Wall
				if col - flexible_cells_margin_columns == flexible_cell_area_bounds.size.x - 1 or cell_visibility_mask[_point_coord_to_flexible_mask_index(row, col + 1)]: 
					st.add_vertex(upper_back_right)
					st.add_vertex(upper_front_right)
					st.add_vertex(lower_back_right)
					
					st.add_vertex(upper_front_right)
					st.add_vertex(lower_front_right)
					st.add_vertex(lower_back_right)
				
				# Front wall (faces away from camera normally, so vertex winding is reversed)
				if row - flexible_cells_margin_rows == flexible_cell_area_bounds.size.y - 1 or cell_visibility_mask[_point_coord_to_flexible_mask_index(row + 1, col)]: 
					st.add_vertex(upper_front_right)
					st.add_vertex(upper_front_left)
					st.add_vertex(lower_front_right)
					
					st.add_vertex(upper_front_left)
					st.add_vertex(lower_front_left)
					st.add_vertex(lower_front_right)
			
	st.generate_normals()
	st.generate_tangents()
	mesh = st.commit()

## Assumes rectangular array of points that matches size of flex rows / columns
func set_flexible_vertices(new_vertices: Array[Vector3], cell_vis_mask: Array[bool] = []) -> void:
	
	flexible_vertices = new_vertices
	cell_visibility_mask = cell_vis_mask
