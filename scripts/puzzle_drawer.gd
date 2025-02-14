extends Control

var cell_size_px: float = 32

var puzzle: Puzzle

func init(puz: Puzzle) -> void:
	puzzle = puz

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	
	if not puzzle: return
	
	for row in puzzle.input_size.x:
		for col in puzzle.input_size.y:
			
			var cell: Puzzle.InputCell = puzzle.get_input_cell(row, col)
			
			if cell.player_input == Puzzle.INPUT_TYPE.EMPTY: continue
			
			var coord = puzzle.input_to_board_coordinate(Vector2i(row, col))
			
			# Swizzle
			var pos = Vector2(coord.y, coord.x) * cell_size_px
			var offset = Vector2(cell_size_px, cell_size_px) / 2
			
			if cell.player_input == Puzzle.INPUT_TYPE.COLORED:
				var rect: = Rect2(pos, Vector2(cell_size_px, cell_size_px))
				draw_rect(rect, Color.BLACK)
			elif cell.player_input == Puzzle.INPUT_TYPE.CROSSED:
				var center = pos + offset
				draw_line(center - Vector2(cell_size_px, cell_size_px) / 4, center + Vector2(cell_size_px, cell_size_px) / 4, Color.WHITE, 2)
				draw_line(center + Vector2(-cell_size_px, cell_size_px) / 4, center + Vector2(cell_size_px, -cell_size_px) / 4, Color.WHITE, 2)
	
