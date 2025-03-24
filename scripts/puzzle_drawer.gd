extends Control

var text_color: Color = Color.WHITE
var line_color: Color = Color(1, 1, 1, 0.7)

var cell_size_px: float = 32

var puzzle: Puzzle

func init(puz: Puzzle, cell_size: int = 32) -> void:
	puzzle = puz
	
	cell_size_px = cell_size

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	
	if not puzzle: return
	
	# Draw grid
	# Horizontal
	for row in puzzle.input_size.x + 1:
		var a: Vector2 = puzzle.input_to_board_coordinate(Vector2i(row, 0))
		a = Vector2(a.y, a.x) * cell_size_px
		
		var b: Vector2 = puzzle.input_to_board_coordinate(Vector2i(row, puzzle.input_size.y))
		b = Vector2(b.y, b.x) * cell_size_px
		
		draw_line(a , b, line_color, 2)
	
	# Vertical
	for col in puzzle.input_size.y + 1:
		var a: Vector2 = puzzle.input_to_board_coordinate(Vector2i(0, col))
		a = Vector2(a.y, a.x) * cell_size_px
		
		var b: Vector2 = puzzle.input_to_board_coordinate(Vector2i(puzzle.input_size.x, col))
		b = Vector2(b.y, b.x) * cell_size_px
		
		draw_line(a , b, line_color, 2)
	
	# Input Cells
	for row in puzzle.input_size.x:
		for col in puzzle.input_size.y:
			
			var cell: Puzzle.InputCell = puzzle.get_input_cell(row, col)
			
			if cell.player_input == Puzzle.INPUT_TYPE.EMPTY: continue
			
			var coord = puzzle.input_to_board_coordinate(Vector2i(row, col))
			
			# Swizzle
			var pos = Vector2(coord.y, coord.x) * cell_size_px
			var offset = Vector2(cell_size_px, cell_size_px) / 2
			
			if cell.player_input == Puzzle.INPUT_TYPE.COLORED:
				#var rect: = Rect2(pos, Vector2(cell_size_px, cell_size_px))
				#draw_rect(rect, Color.BLACK)
				pass
			elif cell.player_input == Puzzle.INPUT_TYPE.CROSSED:
				var center = pos + offset
				draw_line(center - Vector2(cell_size_px, cell_size_px) / 4, center + Vector2(cell_size_px, cell_size_px) / 4, Color.WHITE, 2)
				draw_line(center + Vector2(-cell_size_px, cell_size_px) / 4, center + Vector2(cell_size_px, -cell_size_px) / 4, Color.WHITE, 2)
	
