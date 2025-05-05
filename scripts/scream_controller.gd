extends AudioStreamPlayer3D

func init(puzzle: Puzzle) -> void:
	puzzle.input_attempt_made.connect(_on_puzzle_input_attempt_made)

func _on_puzzle_input_attempt_made(cell: Puzzle.InputCell, row: int, col: int) -> void:
	if cell.is_colored():
		if not playing:
			play()
