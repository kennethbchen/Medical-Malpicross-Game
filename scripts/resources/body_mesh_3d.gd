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

# (x, y) / (column, row)
var flexible_area_bounds: Rect2i

# (x, y) / (columns, rows)
var total_grid_size: Vector2i

var total_point_grid_size : Vector2i

var cell_size = 0


var cell_visibility_mask: Array[bool]

func init(input_rows: int, input_columns: int, cell_size: float) -> void:
	

	self.flexible_rows = input_rows
	self.flexible_columns = input_columns
	self.cell_size = cell_size
	
	# Add small amount to column / row count so that bottom and right edges are considered "in" the rect
	self.flexible_area_bounds = Rect2(flexible_cells_margin_columns, flexible_cells_margin_rows, input_columns + 0.00001, input_rows + 0.00001)
	
	
	self.total_grid_size = Vector2i(input_columns + flexible_cells_margin_columns * 2, input_rows + flexible_cells_margin_rows * 2)
	
	# Count fenceposts instead of fence segments
	self.total_point_grid_size = total_grid_size + Vector2i(1, 1)
	
	# Calculate offset so that mesh is generated such that
	# The center of the input area is at the origin
	self.origin_position_offset = -Vector3((total_grid_size.x * cell_size) / 2.0, 0, (total_grid_size.y * cell_size) / 2.0)
	
	

	

	"""
	# Create array of triangle vertex indices to define triangles
	
	# quad count = total_grid_size.x * total_grid_size.y
	# triangle count = quad count * 2 triangles per quad
	# tri_indices_count = triangle count * 3 vertices per triangle
	var tri_indices_count: int = total_grid_size.x * total_grid_size.y * 2 * 3
	
	indices = PackedInt32Array()
	indices.resize(tri_indices_count)
	
	# Make 1 quad / 2 triangles / 6 indices at a time
	for row in total_grid_size.y:
		
		for col in total_grid_size.x:
			
			# index for indices array
			var tri_ind = (col * 6) + ( total_grid_size.x * row * 6 ) 
			
			# index for vertices array
			var vertex_ind = col + (total_point_grid_size.x) * row
			
			# Upper triangle
			indices[tri_ind + 0] = vertex_ind + 0
			indices[tri_ind + 1] = vertex_ind + 1
			indices[tri_ind + 2] = vertex_ind + total_point_grid_size.x
			
			# Lower triangle
			indices[tri_ind + 3] = vertex_ind + 1
			indices[tri_ind + 4] = vertex_ind + 1 + total_point_grid_size.x
			indices[tri_ind + 5] = vertex_ind + total_point_grid_size.x
	"""

	mesh = ArrayMesh.new()

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
	
	# Modify height to give body mesh curvature
	# Based on coordinate
	var x_coord_center = (flexible_columns + flexible_cells_margin_columns * 2) / 2.0
	var x_diff = abs(pow(x_coord_center - col, 2) * 0.05)
	new_vert.y = -x_diff
	
	return new_vert
	

func _process(delta: float) -> void:
	
	if cell_size <= 0: 
		# Not initalized yet
		return
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Generate mesh one quad (2 tris, 6 verts) at a time.
	# NOTE: Do we really subtract 1 from total_point_grid size?
	for row in total_point_grid_size.y - 1:
		for col in total_point_grid_size.x - 1:
			
			var is_flexible_vertex: bool = flexible_area_bounds.has_point(Vector2i(col, row))
			var generate_outer: bool = true
			
			if is_flexible_vertex:
				
				# Convert from point grid space to flexible point space by subtracting margin sizes
				var mask_index: int = col - flexible_cells_margin_columns + ( (row - flexible_cells_margin_rows) * (flexible_columns))
				
				# Flexible cell might be missing
				generate_outer = cell_visibility_mask[mask_index]
				

			if generate_outer:
				var ind = col + (total_point_grid_size.x) * row
				
				var top_left: Vector3 = _get_init_vertex_position(row, col)
				var top_right: Vector3 = _get_init_vertex_position(row, col + 1)
				var bottom_left: Vector3 = _get_init_vertex_position(row + 1, col)
				var bottom_right: Vector3 = _get_init_vertex_position(row + 1, col + 1)
				
				# TODO: Because the cell sizes are variable on the margins,
				# we can't calculate the UVs correctly only based on row / col
				# we need to use real coordinate space positions
				
				st.set_material(temp_outer_mat)
				# Tri 1
				st.set_uv(Vector2(col, row) / (Vector2(total_point_grid_size) - Vector2(1, 1)))
				st.add_vertex(top_left)
				
				st.set_uv(Vector2(col + 1, row) / (Vector2(total_point_grid_size) - Vector2(1, 1)))
				st.add_vertex(top_right)
				
				st.set_uv(Vector2(col, row + 1) / (Vector2(total_point_grid_size) - Vector2(1, 1)))
				st.add_vertex(bottom_left)
				
				# Tri 2
				st.set_uv(Vector2(col + 1, row) / (Vector2(total_point_grid_size) - Vector2(1, 1)))
				st.add_vertex(top_right)
				
				st.set_uv(Vector2(col + 1, row + 1) / (Vector2(total_point_grid_size) - Vector2(1, 1)))
				st.add_vertex(bottom_right)
				
				st.set_uv(Vector2(col, row + 1) / (Vector2(total_point_grid_size) - Vector2(1, 1)))
				st.add_vertex(bottom_left)
			elif is_flexible_vertex and not generate_outer:
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
			
	st.generate_normals()
	st.generate_tangents()
	mesh = st.commit()

	"""
	# Regenerate outer body
	var x_coord_center = (flexible_columns + flexible_cells_margin_columns * 2) / 2.0
	
	# Apply height biases
	# The closer a column is to the center of the body -> The higher the vert is
	for vert_index in vertices.size():
		
		# (x, y) / (column, row)
		var vert_coord: Vector2 = Vector2(vert_index % total_point_grid_size.x, vert_index / total_point_grid_size.x )
		
		var x_diff = abs(pow(x_coord_center - vert_coord.x, 2) * 0.05)
		vertices[vert_index].y = -x_diff
		
	
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.surface_set_material(0, temp_outer_mat)
	
	if cell_visibility_mask.size() != flexible_rows * flexible_columns:
		push_warning("cell_visibility_mask for body_mesh_3d.set_flexible_vertices() has an invalid size")
		return
		
	# Generate inner body
	surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var inner_body_vertices: PackedVector3Array
	var inner_body_normals: PackedVector3Array
	
	var new_geometry: bool = false
	
	for row in flexible_rows:
		for col in flexible_columns:
			
			var inner_body_depth: float = 2
			
			# First, check if we need to draw the inner body for this cell
			var mask_index: int = col + (row * (flexible_columns))
			
			if cell_visibility_mask[mask_index]:
				# Skip
				continue
			
			new_geometry = true
		
			# Convert from flexible cell space to body cell space by adding a margin offset
			var margin_offset: Vector3 = Vector3(flexible_area_bounds.position.x, 0, flexible_area_bounds.position.y)
			
			# Vertices on the cube (so, 8 vertices) that this cell represents
			
			# We can calculate these as new based on row / col
			var lower_back_left: Vector3 = origin_position_offset + (Vector3(col, -inner_body_depth, row) + margin_offset) * cell_size
			var lower_back_right: Vector3 = origin_position_offset + (Vector3(col + 1, -inner_body_depth, row) + margin_offset) * cell_size
			var lower_front_left: Vector3 = origin_position_offset + (Vector3(col, -inner_body_depth, row + 1) + margin_offset) * cell_size
			var lower_front_right: Vector3 = origin_position_offset + (Vector3(col + 1, -inner_body_depth, row + 1) + margin_offset) * cell_size
			
			# We grab the correct vertex from the vertices array
			# Take row / col and convert from flexible space to body space by adding margin size
			var upper_back_left: Vector3 = vertices[(col + flexible_cells_margin_columns) + (total_point_grid_size.x) * (row + flexible_cells_margin_rows)]
			var upper_back_right: Vector3 = vertices[(col + flexible_cells_margin_columns + 1) + (total_point_grid_size.x) * (row + flexible_cells_margin_rows)]
			var upper_front_left: Vector3 = vertices[(col + flexible_cells_margin_columns) + (total_point_grid_size.x) * (row + flexible_cells_margin_rows + 1)]
			var upper_front_right: Vector3 = vertices[(col + flexible_cells_margin_columns + 1) + (total_point_grid_size.x) * (row + flexible_cells_margin_rows + 1)]


			# Create floor, which does not move
			# Create triangles
			inner_body_vertices.push_back(lower_back_left)
			inner_body_vertices.push_back(lower_back_right)
			inner_body_vertices.push_back(lower_front_left)
			
			inner_body_vertices.push_back(lower_back_right)
			inner_body_vertices.push_back(lower_front_right)
			inner_body_vertices.push_back(lower_front_left)
			
			inner_body_normals.push_back(Vector3(0, 1, 0))
			inner_body_normals.push_back(Vector3(0, 1, 0))
			inner_body_normals.push_back(Vector3(0, 1, 0))
			inner_body_normals.push_back(Vector3(0, 1, 0))
			inner_body_normals.push_back(Vector3(0, 1, 0))
			inner_body_normals.push_back(Vector3(0, 1, 0))
			
			# Create wall triangles
			# Back wall
			if row == 0 or cell_visibility_mask[col + ( (row - 1) * (flexible_columns))]: 

				inner_body_vertices.push_back(upper_back_left)
				inner_body_vertices.push_back(upper_back_right)
				inner_body_vertices.push_back(lower_back_left)
				
				inner_body_vertices.push_back(upper_back_right)
				inner_body_vertices.push_back(lower_back_right)
				inner_body_vertices.push_back(lower_back_left)
			
			# Check if each wall needs to be made
			# Doesn't need to be made if it neighbors another hole
			
			# Left Wall
			
			if col == 0 or cell_visibility_mask[col - 1 + (row * (flexible_columns))]: 
				inner_body_vertices.push_back(upper_front_left)
				inner_body_vertices.push_back(upper_back_left)
				inner_body_vertices.push_back(lower_front_left)
			
				inner_body_vertices.push_back(upper_back_left)
				inner_body_vertices.push_back(lower_back_left)
				inner_body_vertices.push_back(lower_front_left)
			
			# Right Wall
			if col == flexible_area_bounds.size.x - 1 or cell_visibility_mask[col + 1 + (row * (flexible_columns))]: 
				inner_body_vertices.push_back(upper_back_right)
				inner_body_vertices.push_back(upper_front_right)
				inner_body_vertices.push_back(lower_back_right)
				
				inner_body_vertices.push_back(upper_front_right)
				inner_body_vertices.push_back(lower_front_right)
				inner_body_vertices.push_back(lower_back_right)
			
			# Front wall (faces away from camera normally)
			
			if row == flexible_area_bounds.size.y - 1 or cell_visibility_mask[col + ( (row + 1) * (flexible_columns))]: 
				inner_body_vertices.push_back(upper_front_right)
				inner_body_vertices.push_back(upper_front_left)
				inner_body_vertices.push_back(lower_front_right)
				
				inner_body_vertices.push_back(upper_front_left)
				inner_body_vertices.push_back(lower_front_left)
				inner_body_vertices.push_back(lower_front_right)
			
			
			
			
			
			
	if not new_geometry: return
	
	#print(inner_body_vertices)
	surface_array[Mesh.ARRAY_VERTEX] = inner_body_vertices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.surface_set_material(1, temp_inner_mat)
	"""

func flexible_to_body_coordinate(column: int, row: int) -> Vector2:
	
	return Vector2.ZERO

## Assumes rectangular array of points that matches size of flex rows / columns
func set_flexible_vertices(new_vertices: Array[Vector3], cell_vis_mask: Array[bool] = []) -> void:
	
	cell_visibility_mask = cell_vis_mask
	
	"""
	for new_vert_index in range(new_vertices.size()):
		# row column
		# Add +1 to flexible_columns/rows to convert from grid space to point space
		var flexible_vertex_coord: Vector2i = Vector2i(new_vert_index / (flexible_columns + 1), new_vert_index % (flexible_columns + 1) )
		
		# Add offset to account for margins
		flexible_vertex_coord += Vector2i(flexible_cells_margin_rows, flexible_cells_margin_columns)
		
		# Now, convert this vertex position into an index for vertices array
		var flexible_vertex_index: int = flexible_vertex_coord.y + (total_point_grid_size.x) * flexible_vertex_coord.x
		
		vertices[flexible_vertex_index] = new_vertices[new_vert_index]
	
	# Handle cell visibility
	if cell_visibility_mask.size() != flexible_rows * flexible_columns:
		push_warning("cell_visibility_mask for body_mesh_3d.set_flexible_vertices() has an invalid size")
		return

	for row in flexible_rows:
		for col in flexible_columns:
			
			# Calculate the index where the triangles that define this cell is found
			# Start with vertex coord in flexible space
			var vertex_coord: Vector2i = Vector2i(row, col)
			
			# convert from flexible row/col space to total point grid space
			# by adding margin sizes
			vertex_coord += Vector2i(flexible_cells_margin_rows, flexible_cells_margin_columns)
			
			# Convert this vertex coord to triangle index
			# The next 5 indexes are a part of the cell
			var first_tri_index = (vertex_coord.y * 6) + ( total_grid_size.x * vertex_coord.x * 6 )
			
			var mask_index: int = col + (row * (flexible_columns))
			# Hide this cell by making the trangles that it is made of have negative indexes
			# NOTE: negative index on surface_mesh array seems to be undefined behavior
			# but it does seem to work...?
			
			# It's convenient because we don't have to change the size of the indices array to exclude triangles
			# and we don't have to change the numerical value of the index (so we don't have to remember what the original value was)
			
			# This weirdness could be avoided by just regenerating the index array every time
			# That way, we could skip triangles by just not including them in the array
			
			if cell_visibility_mask[mask_index]:
				indices[first_tri_index + 0] = abs(indices[first_tri_index + 0])
				indices[first_tri_index + 1] = abs(indices[first_tri_index + 1])
				indices[first_tri_index + 2] = abs(indices[first_tri_index + 2])
				indices[first_tri_index + 3] = abs(indices[first_tri_index + 3])
				indices[first_tri_index + 4] = abs(indices[first_tri_index + 4])
				indices[first_tri_index + 5] = abs(indices[first_tri_index + 5])
			else:
				indices[first_tri_index + 0] = -abs(indices[first_tri_index + 0])
				indices[first_tri_index + 1] = -abs(indices[first_tri_index + 1])
				indices[first_tri_index + 2] = -abs(indices[first_tri_index + 2])
				indices[first_tri_index + 3] = -abs(indices[first_tri_index + 3])
				indices[first_tri_index + 4] = -abs(indices[first_tri_index + 4])
				indices[first_tri_index + 5] = -abs(indices[first_tri_index + 5])
				
	"""
