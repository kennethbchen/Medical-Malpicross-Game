extends SubViewport

@onready var ui_container: GridContainer = $PuzzleUIContainer

var cell_size_px: int = 32

var rows: int
var columns: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init(puzzle: Puzzle) -> void:
	rows = puzzle.board_size.x
	columns = puzzle.board_size.y
	
	size = Vector2(columns, rows) * cell_size_px
	
	ui_container.columns = columns

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
