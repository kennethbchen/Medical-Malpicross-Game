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

func _ready() -> void:
	
	var puzzle: Puzzle = Puzzle.new(puzzle_string)
	var board_size = puzzle.board_size
	
	board_cell_rows = board_size.x
	board_cell_columns = board_size.y
	
	# n board cell columns / rows means that 
	# the point sim will have n + 3 columns / rows of points
	# because the outer perimeter of cells is fixed to give the sim structure
	# and don't wiggle around, so we don't count them as part of the board
	sim_point_rows = board_cell_rows + 3
	sim_point_columns = board_cell_columns + 3
	
	point_mass_sim.generate_point_grid(sim_point_columns, sim_point_rows, 50)
	
	puzzle_viewport.init(puzzle)

func get_board_points() -> Array[Vector2]:
	
	var output: Array[Vector2]
	
	for row in range(1, sim_point_rows - 1):
		for col in range(1, sim_point_columns - 1):
			output.push_back(point_mass_sim.get_point(row, col).position)

	return output

func _process(delta: float) -> void:
	grid_mesh.construct_from_points(get_board_points(), sim_point_rows - 2, sim_point_columns - 2)
	
class PuzzleCell:
	extends RefCounted

class EmptyCell:
	extends PuzzleCell

class InputCell:
	extends PuzzleCell
	
	enum INPUT_TYPE {EMPTY, CROSSED, COLORED}
	
	var player_input: INPUT_TYPE
	var correct_input: INPUT_TYPE
	
class HintCell:
	extends PuzzleCell
	
	var value: int
	
class PointMassQuad:
	extends RefCounted
	
	var p1: PointMassSim.PointMass
	var p2: PointMassSim.PointMass
	var p3: PointMassSim.PointMass
	var p4: PointMassSim.PointMass
	
	func init(p1: PointMassSim.PointMass, p2: PointMassSim.PointMass, p3: PointMassSim.PointMass, p4: PointMassSim.PointMass) -> void:
		self.p1 = p1
		self.p2 = p2
		self.p3 = p3
		self.p4 = p4
	
	func is_in_quad(test_position: Vector2):
		pass
