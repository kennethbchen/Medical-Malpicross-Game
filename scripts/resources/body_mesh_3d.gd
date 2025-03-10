extends MeshInstance3D

class_name BodyMesh3D

@export var temp_mat: StandardMaterial3D

var flexible_cells_margin_rows: int = 2
var flexible_cells_margin_columns: int = 2

var margin_cell_column_size: float = 0.75
var margin_cell_row_size: float = 0.75

var flexible_rows: int
var flexible_columns: int

var origin_position_offset: Vector3

# (x, y) / (column, row)
var flexible_area_bounds: Rect2i

var total_point_grid_size : Vector2i

var cell_size = 0
var vertices: PackedVector3Array
var indices: PackedInt32Array
var uvs: PackedVector2Array

func init(input_rows: int, input_columns: int, cell_size: float) -> void:
	

	flexible_rows = input_rows
	flexible_columns = input_columns
	cell_size = cell_size
	
	# Add small amount to column / row count so that bottom and right edges are considered "in" the rect
	flexible_area_bounds = Rect2(flexible_cells_margin_columns, flexible_cells_margin_rows, input_columns + 0.00001, input_rows + 0.00001)
	
	# (x, y) / (columns, rows)
	var total_grid_size: Vector2i = Vector2i(input_columns + flexible_cells_margin_columns * 2, input_rows + flexible_cells_margin_rows * 2)
	
	# Count fenceposts instead of fence segments
	total_point_grid_size = total_grid_size + Vector2i(1, 1)
	
	# Calculate offset so that mesh is generated such that
	# The center of the input area is at the origin
	origin_position_offset = -Vector3((total_grid_size.x * cell_size) / 2.0, 0, (total_grid_size.y * cell_size) / 2.0)
	
	# Create base array of vertex positions
	var vert_count: int = total_point_grid_size.x * total_point_grid_size.y
	
	vertices = PackedVector3Array()
	vertices.resize(vert_count)
	
	uvs = PackedVector2Array()
	uvs.resize(vert_count)
	
	for row in total_point_grid_size.y:
		for col in total_point_grid_size.x:
			
			var ind = col + (total_point_grid_size.x) * row
			
			vertices[ind] = origin_position_offset + Vector3(col, 0, row) * cell_size
			
			# Margins have different size
			if row < flexible_cells_margin_rows:
				vertices[ind].z += -margin_cell_row_size * (flexible_cells_margin_rows - row)
				
			if row > flexible_cells_margin_rows + input_rows:
				# NOTE: Might not be the right multiplier calculation
				vertices[ind].z += margin_cell_row_size * (flexible_cells_margin_rows - (total_point_grid_size.y - row) + 1)
			
			if col < flexible_cells_margin_columns:
				vertices[ind].x += -margin_cell_column_size * (flexible_cells_margin_columns - col)

			if col > flexible_cells_margin_columns + input_columns:
				# NOTE: Might not be the right multiplier calculation
				vertices[ind].x += margin_cell_column_size * (flexible_cells_margin_columns - (total_point_grid_size.x - col) + 1)
			
			# TODO: Because the cell sizes are variable on the margins,
			# we can't calculate the UVs correctly only based on row / col
			# we need to use real coordinate space positions
			uvs[ind] = Vector2(col, row) / (Vector2(total_point_grid_size) - Vector2(1, 1))

	
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

	
	
	# Offset position so that mesh is centered around the origin
	var offset = total_grid_size * cell_size / 2
	#position = Vector3(-offset.x, -0.1, -offset.y)
	
	mesh = ArrayMesh.new()

func _process(delta: float) -> void:
	
	var x_coord_center = (flexible_columns + flexible_cells_margin_columns * 2) / 2.0
	
	# Apply height biases
	# The closer a column is to the center of the body -> The higher the vert is
	for vert_index in vertices.size():
		
		# (x, y) / (column, row)
		var vert_coord: Vector2 = Vector2(vert_index % total_point_grid_size.x, vert_index / total_point_grid_size.x )
		
		var x_diff = abs(pow(x_coord_center - vert_coord.x, 2) * 0.05)
		vertices[vert_index].y = -x_diff
		
	
	# Regenerate mesh
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.surface_set_material(0, temp_mat)
	
## Assumes rectangular array of points that matches size of flex rows / columns
func set_flexible_vertices(new_vertices: Array[Vector3]) -> void:
	#print(new_vertices)
	#print(flexible_area_bounds)
	
	# TODO fix this so that mesh isn't broken
	# We have to convert sim coordinates i think
	for new_vert_index in range(new_vertices.size()):
		
		
		# row column
		# Add +1 to flexible_columns/rows to convert from grid space to point space
		var new_flexible_coord: Vector2i = Vector2i(new_vert_index / (flexible_columns + 1), new_vert_index % (flexible_columns + 1) )
		
		# Add more to new_flexible_coord to account for margins
		var offset: Vector2i = Vector2i(flexible_cells_margin_rows, flexible_cells_margin_columns)
		new_flexible_coord += offset
		
		#print(new_flexible_coord)
		
		# Now, convert this vertex position into an index for vertices array
		var new_flexible_index: int = new_flexible_coord.y + (total_point_grid_size.x) * new_flexible_coord.x
		
		vertices[new_flexible_index] = new_vertices[new_vert_index]
