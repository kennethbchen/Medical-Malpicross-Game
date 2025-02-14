extends Node2D

@onready var point_mass_sim: Node2D = $PointGridSim

@onready var grid_mesh: GridMesh2D = $GridMesh2D

@onready var puzzle_viewport: SubViewport = $PuzzleViewport

var puzzle_string: String = \
"""0 1 1 1 0
0 0 0 0 0
0 1 0 1 1
0 1 0 0 0
0 1 1 1 0"""

var sim_point_rows: int
var sim_point_columns: int

var board_cell_rows: int
var board_cell_columns: int

var puzzle: Puzzle

# 2D array (row, col) of quads in the input space
var input_quads: Array

var selected_cell: Vector2i

func _ready() -> void:
	
	puzzle = Puzzle.new(puzzle_string)
	
	puzzle.get_input_cell(0,0).set_input_value(Puzzle.INPUT_TYPE.CROSSED)
	board_cell_rows = puzzle.board_size.x
	board_cell_columns = puzzle.board_size.y
	
	# n board cell columns / rows means that 
	# the point sim will have n + 3 columns / rows of points
	# because the outer perimeter of cells is fixed to give the sim structure
	# and don't wiggle around, so we don't count them as part of the board
	sim_point_rows = board_cell_rows + 3
	sim_point_columns = board_cell_columns + 3
	
	point_mass_sim.generate_point_grid(sim_point_columns, sim_point_rows, 50)
	
	puzzle_viewport.init(puzzle)
	
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
				point_mass_sim.get_point(sim_coord.x, sim_coord.y),
				point_mass_sim.get_point(sim_coord.x + 1, sim_coord.y),
				point_mass_sim.get_point(sim_coord.x + 1, sim_coord.y + 1),
				point_mass_sim.get_point(sim_coord.x, sim_coord.y + 1)
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
	grid_mesh.construct_from_points(get_board_points(), sim_point_rows - 2, sim_point_columns - 2)
	
	# Check for input
	selected_cell = _get_selected_cell()
	puzzle_viewport.highlight_cell(selected_cell)

func get_board_points() -> Array[Vector2]:
	
	var output: Array[Vector2]
	
	for row in range(1, sim_point_rows - 1):
		for col in range(1, sim_point_columns - 1):
			output.push_back(point_mass_sim.get_point(row, col).position)

	return output

	
func _get_selected_cell():
	
	for row in input_quads.size():
		for col in input_quads[row].size():
			if input_quads[row][col].contains_point(get_global_mouse_position()):
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
