extends MeshInstance2D

class_name GridMesh2D

@export var max_uv: Vector2 = Vector2(1, 1)
func _ready() -> void:
	pass # Replace with function body.

## Assumes rectangular array of points
func construct_from_points(points: Array[Vector2], rows: int, columns: int) -> void:
	
	if not is_inside_tree() or not is_node_ready():
		return

	if not is_instance_valid(mesh):
		mesh = ArrayMesh.new()

	var am := mesh as ArrayMesh
	if am.get_surface_count() > 0:
		am.clear_surfaces()
	
	var vertices = PackedVector2Array()
	
	var uvs = PackedVector2Array()
	
	# Unless the mesh is a square, not all of the UV space will be used to avoid stretching
	# Either the max x or y UV has to shrink in order to 
	# fit the aspect ratio of the grid
	var max_uv_values: Vector2 = Vector2(1, 1)
	"""
	if rows > columns:
		max_uv_values.x = ((columns - 1) / float(rows - 1) )
	elif columns > rows:
		max_uv_values.y = ((rows - 1) / float(columns - 1) )
	"""
	
	
	max_uv_values = max_uv
	# Each point that isn't on the rightmost / bottommost edge is the
	# top left point of a quad
	for row in range(rows - 1): # rows - 1
		for col in range(columns - 1):

			# (row, col) defines the top left position of the quad
			# we are currently looking at
			
			# convert (row, col) to an index in points
			# https://softwareengineering.stackexchange.com/questions/212808/treating-a-1d-data-structure-as-2d-grid
			
			# Make two triangles to construct one quad
			# First triangle
			
			# Top Left
			vertices.push_back(points[col + columns * row])
			uvs.push_back(Vector2(float(col) / (columns - 2), float(row) / (rows - 2) ) * max_uv_values)
			# Top Right
			vertices.push_back(points[(col + 1) + columns * row])
			uvs.push_back(Vector2(float(col + 1) / (columns - 2), float(row) / (rows - 2) )  * max_uv_values)

			# Bottom Left
			vertices.push_back(points[col + (columns * (row + 1))])
			uvs.push_back(Vector2(float(col) / (columns - 2), float(row + 1) / (rows - 2) )  * max_uv_values)

			# Second Triangle
			
			# Top Right
			vertices.push_back(points[(col + 1) + columns * row])
			uvs.push_back(Vector2(float(col + 1) / (columns - 2), float(row) / (rows - 2) ) * max_uv_values)

			# Bottom Right
			vertices.push_back(points[(col + 1) + columns * (row + 1)])
			uvs.push_back(Vector2(float(col + 1) / (columns - 2), float(row + 1) / (rows - 2) ) * max_uv_values)

			# Bottom Left
			vertices.push_back(points[col + (columns * (row + 1))])
			uvs.push_back(Vector2(float(col) / (columns - 2), float(row + 1) / (rows - 2) ) * max_uv_values)


	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs

	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
func push_quad(top_left_position: Vector2, quad_size: float) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
