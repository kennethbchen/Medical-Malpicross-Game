extends Node3D

@export var camera: Camera3D

@onready var flesh_sim: Node3D = $FleshSim3D

@onready var grid_mesh: GridMesh3D = $GridMesh3D

@onready var puzzle_viewport: SubViewport = $PuzzleViewport

@onready var body_mesh: BodyMesh3D = $BodyMesh3D

var test_puzzles: Array[String] = [
	"""0 1 1 1 0
0 0 0 0 0
0 1 0 1 1
0 1 0 0 0
0 1 1 1 0""",

"""0 1 1 1 0
0 0 1 0 0
0 1 0 1 1""",

"""0 1 1 1
1 1 1 0
0 1 0 1
0 1 0 0
0 1 1 1""",

"""0 1 1 1
1 1 1 0"""
]

var puzzle_string: String = ""

var sim_point_rows: int
var sim_point_columns: int

var board_cell_rows: int
var board_cell_columns: int

var puzzle: Puzzle

# 2D array (row, col) of quads in the input space
var input_quads: Array

# In input space
var selected_cell: Vector2i

var sim_segment_size: float = 50

var cell_size: float = 0.5

var cell_scale_factor: float = cell_size / sim_segment_size

# In sim space
var cursor_position: Vector2i

func _ready() -> void:
	puzzle_string = test_puzzles.pick_random()
	
	puzzle = Puzzle.new(puzzle_string)
	
	board_cell_rows = puzzle.board_size.x
	board_cell_columns = puzzle.board_size.y
	
	# n board cell columns / rows means that 
	# the point sim will have n + 3 columns / rows of points
	# because the outer perimeter of cells is fixed to give the sim structure
	# and don't wiggle around, so we don't count them as part of the board
	sim_point_rows = board_cell_rows + 3
	sim_point_columns = board_cell_columns + 3
	
	flesh_sim.init(puzzle, sim_point_columns, sim_point_rows, sim_segment_size)
	
	puzzle_viewport.init(puzzle)
	
	var grid_mesh_material: StandardMaterial3D = StandardMaterial3D.new()
	grid_mesh_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grid_mesh_material.albedo_texture = puzzle_viewport.get_texture()
	grid_mesh_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	grid_mesh.init(grid_mesh_material)

	body_mesh.init(puzzle.input_size.x, puzzle.input_size.y, cell_size)
	
	# Create input_quads so that we can interpret mouse input
	for row in puzzle.input_size.x:
		
		var row_data: Array[PointMassQuad]
		for col in puzzle.input_size.y:
			
			# Convert board-space (row, col) to the position of the 
			# corresponding top left point in sim-space
			# First, convert from input space to board space 
			# Then, convert from board space to sim space by addding (1,1)
			var sim_coord: Vector2i = puzzle.input_to_board_coordinate(Vector2i(row, col)) + Vector2i(1, 1)

			var new_quad: PointMassQuad = PointMassQuad.new(
				flesh_sim.get_point(sim_coord.x, sim_coord.y),
				flesh_sim.get_point(sim_coord.x + 1, sim_coord.y),
				flesh_sim.get_point(sim_coord.x + 1, sim_coord.y + 1),
				flesh_sim.get_point(sim_coord.x, sim_coord.y + 1)
				)
			row_data.append(new_quad)

		input_quads.append(row_data)
		
	

func _unhandled_input(event: InputEvent) -> void:
	
	if selected_cell != Vector2i(-1, -1):

		if event.is_action_pressed("game_color"):
			puzzle.toggle_input_colored(selected_cell.x, selected_cell.y)
			
		if event.is_action_pressed("game_cross"):
			puzzle.toggle_input_crossed(selected_cell.x, selected_cell.y)

func _process(delta: float) -> void:

	# Update meshes
	grid_mesh.construct_from_points(get_board_points(), sim_point_rows - 2, sim_point_columns - 2)
	body_mesh.set_flexible_vertices(get_input_points(), get_input_cell_visibility_mask())
	
	# Propagate Mouse input
	selected_cell = _get_selected_cell()
	puzzle_viewport.highlight_cell(selected_cell)
	flesh_sim.set_cursor_position(cursor_position)
	

func _physics_process(delta: float) -> void:
	
	# Raycast camera mouse position to get cursor position
	# We don't need to do a physics raycast, 
	# just project the vector onto the puzzle plane
	# The puzzle plane is the infinite plane in which the puzzle is drawn
	
	# https://samsymons.com/blog/math-notes-ray-plane-intersection/
	var ray_origin: Vector3 = camera.project_ray_origin(get_viewport().get_mouse_position())
	var ray_normal: Vector3 = camera.project_ray_normal(get_viewport().get_mouse_position())
	
	# Grid mesh's transform defines the puzzle plane
	var plane_normal: Vector3 = grid_mesh.global_basis.y
	var plane_origin: Vector3 = grid_mesh.global_position
	
	var denominator = plane_normal.dot(ray_normal)
	
	# Avoid dividing by 0
	if abs(denominator) > 0.0001:
		var difference: Vector3 = plane_origin - ray_origin
		var intersect_distance = difference.dot(plane_normal) / denominator
	
		if intersect_distance > 0.001:
			# Successful Projection
			
			var intersect_position: Vector3 = ray_origin + (ray_normal * intersect_distance)
			
			# Convert from global space to puzzle plane's local space
			var local_intersect_position: Vector3 = grid_mesh.global_transform.inverse() * intersect_position
			
			# Then, convert from puzzle plane local space to sim space
			# Essentially converting from 3D space to pixel space
			local_intersect_position /= cell_scale_factor

			cursor_position = Vector2i(local_intersect_position.x, local_intersect_position.z)

func get_input_cell_visibility_mask() -> Array[bool]:
	
	var output: Array[bool]
	
	
	for row in puzzle.input_size.x:
		for col in puzzle.input_size.y:
			var input_cell = puzzle.get_input_cell(row, col)
			
			# Colored cells are not visible
			output.push_back(input_cell.player_input != Puzzle.INPUT_TYPE.COLORED)

	return output

func get_input_points() -> Array[Vector3]:
	
	var output: Array[Vector3]
	
	for row in puzzle.input_size.x + 1:
		for col in puzzle.input_size.y + 1:
			
			# Convert points from input space to simulation point space
			# First convert input space -> board space
			# Then convert board space -> sim space (add 1,1)
			var sim_coords: Vector2i = puzzle.input_to_board_coordinate(Vector2i(row, col)) + Vector2i(1, 1)
			
			var sim_position: Vector2 = flesh_sim.get_point(sim_coords.x, sim_coords.y).position
			
			
			# Convert from sim space (basically pixels) to 3D space (units)
			# by multiplying by cell_scale_factor
			var posi = Vector3(sim_position.x, 0, sim_position.y) * cell_scale_factor
			#DebugDraw3D.draw_sphere(Vector3(-2, 0, -2) + posi, 0.012, Color.GREEN)
			output.push_back(posi)
			
	return output

func get_board_points() -> Array[Vector3]:
	
	var output: Array[Vector3]
	
	for row in range(1, sim_point_rows - 1):
		for col in range(1, sim_point_columns - 1):
			var sim_position: Vector2 = flesh_sim.get_point(row, col).position
			
			# Convert from sim space (basically pixels) to 3D space (units)
			# by multiplying by cell_scale_factor
			output.push_back(Vector3(sim_position.x, 0, sim_position.y) * cell_scale_factor)

	return output

	
func _get_selected_cell():
	
	# Check every input quad to see if the mouse is inside of it
	for row in input_quads.size():
		for col in input_quads[row].size():
			if input_quads[row][col].contains_point(cursor_position):
				return Vector2i(row, col)

	return Vector2i(-1, -1)

class PointMassQuad:
	extends RefCounted
	
	var p1: PointMassSim.PointMass
	var p2: PointMassSim.PointMass
	var p3: PointMassSim.PointMass
	var p4: PointMassSim.PointMass
	
	func _init(p1: PointMassSim.PointMass, p2: PointMassSim.PointMass, p3: PointMassSim.PointMass, p4: PointMassSim.PointMass) -> void:
		self.p1 = p1
		self.p2 = p2
		self.p3 = p3
		self.p4 = p4
	
	func contains_point(test_position: Vector2) -> bool:
		# TODO
		return _bounding_box_contains_point(test_position)
	
	func _bounding_box_contains_point(test_position: Vector2) -> bool:
		
		var x_vals: Array[float] = [p1.position.x, p2.position.x, p3.position.x, p4.position.x]
		x_vals.sort()
		
		var y_vals: Array[float] = [p1.position.y, p2.position.y, p3.position.y, p4.position.y]
		y_vals.sort()

		return test_position.x >= x_vals[0] and test_position.y >= y_vals[0] and \
			test_position.x < x_vals[-1] and test_position.y < y_vals[-1]
	
	func _to_string() -> String:
		return "{0} {1} {2} {3}".format([p1.position, p2.position, p3.position, p4.position])
