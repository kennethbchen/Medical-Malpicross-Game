extends ColorRect

var pain_decay: float = 0.2

var pain_power: float = 2

var pain_level: float = 0:
	set(value):
		pain_level = clamp(value, 0.0, 1.0)
		
func init(puzzle: Puzzle) -> void:
	puzzle.input_attempt_made.connect(on_input_attempt_made)

func _process(delta: float) -> void:
	# pain_level goes down over time
	if pain_level > 0:
		pain_level = max(pain_level - pain_decay * delta, 0)
	
	material.set("shader_parameter/Opacity", remap(pain_level, 0, 1, 0, 1))
	
func on_input_attempt_made(cell: Puzzle.InputCell, row: int, col: int) -> void:
	if cell.is_colored():
		pain_level += 0.8
