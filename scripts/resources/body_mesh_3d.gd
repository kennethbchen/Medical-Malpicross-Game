extends MeshInstance3D

class_name BodyMesh3D

var cell_size = 0.5

var flexible_cells_margin: int = 0

var flexible_rows: int
var flexible_columns: int

var top_left_start: Vector3

func init(input_rows: int, input_columns: int, cell_size: float) -> void:
	
	flexible_rows = input_rows
	flexible_columns = input_columns
	cell_size = cell_size
	
	top_left_start = Vector3(
		((flexible_columns + flexible_cells_margin * 2) * cell_size) / 2,
		0,
		((flexible_rows + flexible_cells_margin * 2) * cell_size) / 2 
		)
		
	print(top_left_start)

func _process(delta: float) -> void:
		DebugDraw3D.draw_sphere(Vector3.ZERO, 0.125, Color.GREEN)
		DebugDraw3D.draw_sphere(top_left_start, 0.125, Color.WHITE)
