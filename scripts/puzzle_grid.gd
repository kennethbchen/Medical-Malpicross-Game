extends Node2D

@onready var point_mass_sim: Node2D = $PointMassSim

var columns = 10
var rows = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	generate_puzzle_board(8, 8)
	pass

func generate_puzzle_board(grid_columns: int, grid_rows, grid_size: float = 50):
	# n grid columns / rows means that 
	# the point sim will have n + 3 columns / rows of points
	# because the outer perimeter of cells is fixed to give the sim structure
	# and don't wiggle around, so we don't count them as part of the board
	point_mass_sim.generate_point_grid(grid_columns + 3, grid_rows + 3, 50)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
