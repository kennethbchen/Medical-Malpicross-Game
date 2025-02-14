extends SubViewport

@onready var ui_container: Control = $PuzzleUIContainer

@onready var cursor: Control = $Cursor
@onready var puzzle_drawer: Control = $PuzzleDrawer

var current_puzzle: Puzzle

var cell_size_px: int = 32

var rows: int
var columns: int

# TODO
var tile_map: Dictionary[Vector2i, Control]

# (-1, -1) means no selected cell
var selected_cell: Vector2i = Vector2i(-1, -1)

func init(puzzle: Puzzle) -> void:
	current_puzzle = puzzle
	
	puzzle_drawer.init(puzzle)

	rows = puzzle.board_size.x
	columns = puzzle.board_size.y
	
	size = Vector2(columns, rows) * cell_size_px

	var position_offset: = Vector2(cell_size_px / 2, cell_size_px / 2)
	# Populate puzzle UI
	for row in rows:
		for col in columns:
			var pos: Vector2 = Vector2(col, row) * cell_size_px
			
			var cell: Puzzle.PuzzleCell = puzzle.get_board_cell(row, col)
			
			if cell is Puzzle.EmptyCell:
				continue
				
			if cell is Puzzle.InputCell:
				continue
				
			if cell is Puzzle.HintCell:
				var label: = Label.new()
				ui_container.add_child(label)
				
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				label.size = Vector2(cell_size_px, cell_size_px)
				label.position = pos
				label.text = str(cell.value)
				
			
func _process(delta: float) -> void:
	
	if selected_cell == Vector2i(-1, -1):
		cursor.hide()
	else:
		cursor.show()
		
		# Need to swizzle (row, col) -> (col, row)
		var coord = current_puzzle.input_to_board_coordinate(selected_cell)
		cursor.set_cursor_position(Vector2i(coord.y, coord.x) * cell_size_px)

func highlight_cell(coordinate) -> void:
	selected_cell = coordinate
