extends MeshInstance3D

class_name BodyMesh3D

var flexible_cells_margin_rows: int = 1
var flexible_cells_margin_columns: int = 1

var flexible_rows: int
var flexible_columns: int

# (x, y) / (column, row)
var flexible_area_bounds: Rect2i

var cell_size = 0
var vertices: PackedVector3Array
var indices: PackedInt32Array

func init(input_rows: int, input_columns: int, cell_size: float) -> void:
	
	flexible_rows = input_rows
	flexible_columns = input_columns
	cell_size = cell_size
	
	# Add small amount to column / row count so that bottom and right edges are considered "in" the rect
	flexible_area_bounds = Rect2(flexible_cells_margin_columns, flexible_cells_margin_rows, input_columns + 0.00001, input_rows + 0.00001)
	
	# (x, y) / (columns, rows)
	var total_grid_size: Vector2i = Vector2i(input_columns + flexible_cells_margin_columns * 2, input_rows + flexible_cells_margin_rows * 2)
	
	# Count fenceposts instead of fence segments
	var total_point_grid_size: Vector2i = total_grid_size + Vector2i(1, 1)
	
	# Create base array of vertex positions
	var vert_count: int = total_point_grid_size.x * total_point_grid_size.y
	
	vertices = PackedVector3Array()
	vertices.resize(vert_count)
	
	for row in total_point_grid_size.y:
		for col in total_point_grid_size.x:
			
			var ind = col + (total_point_grid_size.x) * row
			
			vertices[ind] = Vector3(col, 0, row) * cell_size

	
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
	position = Vector3(-offset.x, 0, -offset.y)
	
	mesh = ArrayMesh.new()

func _process(delta: float) -> void:
	
	# Regenerate mesh
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

## Assumes rectangular array of points that matches size of flex rows / columns
func set_flexible_vertices(vertices: Array[Vector3]) -> void:
	pass

## Assumes rectangular array of points
func construct_from_points(points: Array[Vector3], rows: int, columns: int) -> void:
	
	if not is_inside_tree() or not is_node_ready():
		return

	if not is_instance_valid(mesh):
		mesh = ArrayMesh.new()

	var am := mesh as ArrayMesh
	if am.get_surface_count() > 0:
		am.clear_surfaces()
	
	var vertices = PackedVector3Array()
	
	var uvs = PackedVector2Array()

	# Each point that isn't on the rightmost / bottommost edge is the
	# top left point of a quad
	for row in range(rows - 1):
		for col in range(columns - 1):

			# (row, col) defines the top left position of the quad
			# we are currently looking at
			
			# convert (row, col) to an index in points
			# https://softwareengineering.stackexchange.com/questions/212808/treating-a-1d-data-structure-as-2d-grid
			
			# Make two triangles to construct one quad
			
			var tl: = points[col + columns * row]
			var tr: = points[(col + 1) + columns * row]
			var bl: = points[col + (columns * (row + 1))]
			var br: = points[(col + 1) + columns * (row + 1)]
			
			# First triangle
			
			# Top Left
			vertices.push_back(tl)
			uvs.push_back(Vector2(float(col) / (columns - 1), float(row) / (rows - 1) ))
			
			# Top Right
			vertices.push_back(tr)
			uvs.push_back(Vector2(float(col + 1) / (columns - 1), float(row) / (rows - 1) ))

			# Bottom Left
			vertices.push_back(bl)
			uvs.push_back(Vector2(float(col) / (columns - 1), float(row + 1) / (rows - 1) ))

			# Second Triangle
			
			# Top Right
			vertices.push_back(tr)
			uvs.push_back(Vector2(float(col + 1) / (columns - 1), float(row) / (rows - 1) ))

			# Bottom Right
			vertices.push_back(br)
			uvs.push_back(Vector2(float(col + 1) / (columns - 1), float(row + 1) / (rows - 1) ))

			# Bottom Left
			vertices.push_back(bl)
			uvs.push_back(Vector2(float(col) / (columns - 1), float(row + 1) / (rows - 1) ))

	#print(vertices)
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
