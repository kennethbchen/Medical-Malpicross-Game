extends SubViewport

@onready var ui_container: Control = $PuzzleUIContainer

@onready var cursor: Control = $Cursor
@onready var puzzle_drawer: Control = $PuzzleDrawer

@onready var solution_texture_rect: TextureRect = $SolutionTexture

var current_puzzle: Puzzle

var cell_size_px: int = 32

var rows: int
var columns: int

# (-1, -1) means no selected cell
var selected_cell: Vector2i = Vector2i(-1, -1)

func init(puzzle: Puzzle, solution_texture: Texture) -> void:
	current_puzzle = puzzle
	
	puzzle_drawer.init(puzzle, cell_size_px)
	cursor.init(puzzle, cell_size_px)
	
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
	
	# Position the solution texture
	solution_texture_rect.hide()
	solution_texture_rect.texture = solution_texture
	solution_texture_rect.size = Vector2(puzzle.input_size.y, puzzle.input_size.x) * cell_size_px
	var tex_origin: Vector2 = puzzle.input_to_board_coordinate(Vector2i(0, 0))
	solution_texture_rect.global_position = Vector2(tex_origin.y, tex_origin.x) * cell_size_px
	
	get_parent().puzzle_solved.connect(_on_puzzle_solved)

func _on_puzzle_solved() -> void:
	
	solution_texture_rect.show()
	puzzle_drawer.hide()
	cursor.hide()
	ui_container.hide()
	
func _process(delta: float) -> void:
	
	if selected_cell == Vector2i(-1, -1):
		# Mouse not on cursor
		cursor.set_cursor_position(Vector2i(-1, -1))
	else:
		
		# Need to swizzle (row, col) -> (col, row)
		var coord = current_puzzle.input_to_board_coordinate(selected_cell)
		cursor.set_cursor_position(Vector2i(coord.y, coord.x) * cell_size_px)

func highlight_cell(coordinate) -> void:
	selected_cell = coordinate
