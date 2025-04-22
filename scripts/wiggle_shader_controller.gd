extends Node

@export var wiggle_materials: Array[ShaderMaterial] = []

var min_wiggle_influence: float = 0.25

var pain_decay: float = 0.2

var pain_power: float = 2

var pain_level: float = 0:
	set(value):
		pain_level = clamp(value, 0.0, 1.0)
		
func init(puzzle: Puzzle) -> void:
	puzzle.input_attempt_made.connect(on_input_cell_changed)

func _process(delta: float) -> void:
	# pain_level goes down over time
	if pain_level > 0:
		pain_level = max(pain_level - pain_decay * delta, 0)
	

	for wiggle_material in wiggle_materials:
		wiggle_material.set("shader_parameter/influence", lerp(min_wiggle_influence, 1.0, pow(pain_level, pain_power)))
		
func on_input_cell_changed(cell: Puzzle.InputCell, row: int, col: int) -> void:
	if cell.is_colored():
		pain_level += 0.8
