extends MeshInstance3D

class_name BodyMesh3D

var cell_size = 0.5

var flexible_cells_margin_rows: int = 1
var flexible_cells_margin_columns: int = 1

var flexible_rows: int
var flexible_columns: int

var top_left_start: Vector3

var input_area_bounds: Rect2i

var st: SurfaceTool

func init(input_rows: int, input_columns: int, cell_size: float) -> void:
	
	flexible_rows = input_rows
	flexible_columns = input_columns
	cell_size = cell_size
	
	# Add small amount to column / row count so that bottom and right edges are considered "in" the rect
	input_area_bounds = Rect2(flexible_cells_margin_columns, flexible_cells_margin_rows, input_columns + 0.00001, input_rows + 0.00001)
	
	var total_grid_size: Vector2i = Vector2i(input_columns + flexible_cells_margin_columns * 2, input_rows + flexible_cells_margin_rows * 2)

	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Make quads
	for row in total_grid_size.y:
		for col in total_grid_size.x:
			
			if input_area_bounds.has_point(Vector2i(col, row)):
				continue
			
			var cur_coord = Vector3(col, 0, row) * cell_size
			var top_right_coord = Vector3(col + 1, 0, row) * cell_size
			var bottom_left_coord = Vector3(col, 0, row + 1) * cell_size
			var bottom_right_coord = Vector3(col + 1, 0, row + 1) * cell_size
			
			# Two triangles
			st.add_vertex(cur_coord)
			st.add_vertex(top_right_coord)
			st.add_vertex(bottom_left_coord)
			
			st.add_vertex(bottom_left_coord)
			st.add_vertex(top_right_coord)
			st.add_vertex(bottom_right_coord)
	
	mesh = st.commit()
	
	# Offset position so that mesh is centered around the origin
	var offset = total_grid_size * cell_size / 2
	position = Vector3(-offset.x, -0.5, -offset.y)
	
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
	
func _process(delta: float) -> void:
		DebugDraw3D.draw_sphere(Vector3.ZERO, 0.125, Color.GREEN)
		DebugDraw3D.draw_sphere(top_left_start, 0.125, Color.WHITE)
