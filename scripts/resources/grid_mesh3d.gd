extends MeshInstance3D

class_name GridMesh3D

var mat: StandardMaterial3D

func init(material: StandardMaterial3D) -> void:
	mat = material

	
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
	am.surface_set_material(0, mat)
	
