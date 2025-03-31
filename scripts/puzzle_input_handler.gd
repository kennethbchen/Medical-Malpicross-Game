extends Node

var puzzle: Puzzle

func init(puzzle) -> void:
	self.puzzle = puzzle
	
	
func color_cell(row, col) -> void:
	
	puzzle.toggle_input_colored(row, col)
	EventBus.screen_shake_requested.emit(0.75)

func cross_cell(row, col) -> void:
	puzzle.toggle_input_crossed(row, col)
