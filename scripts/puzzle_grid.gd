extends Node2D

@onready var point_mass_sim: Node2D = $PointMassSim

var columns = 10
var rows = 10

var puzzle_string: String = \
"""0 1 1 1 0
0 0 0 0 0
0 1 0 1 1
0 1 0 0 0
0 1 1 1 0"""
func _ready() -> void:
	
	var puzzle: Puzzle = Puzzle.new(puzzle_string)
	print(puzzle._solution)
	print(puzzle.get_hints())
	generate_puzzle_board(8, 8)

func generate_puzzle_board(grid_columns: int, grid_rows, grid_size: float = 50):
	# n grid columns / rows means that 
	# the point sim will have n + 3 columns / rows of points
	# because the outer perimeter of cells is fixed to give the sim structure
	# and don't wiggle around, so we don't count them as part of the board
	point_mass_sim.generate_point_grid(grid_columns + 3, grid_rows + 3, 50)

func _process(delta: float) -> void:
	pass
	
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
	
	"""
	# TODO should this go here?
	func draw() -> void:
		pass
	"""	
