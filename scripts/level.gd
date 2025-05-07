extends Node3D

@onready var camera: Camera3D = $CameraSystem/CameraShake/Camera3D

@onready var puzzle_controller: Node3D = $PuzzleController

var test_puzzles: Array[String] = [
	"""0 1 1 1 0
0 0 0 0 0
0 1 0 1 1
0 1 0 0 0
0 1 1 1 0""",

"""0 1 1 1 0
0 0 1 0 0
0 1 0 1 1""",

"""0 1 1 1
1 1 1 0
0 1 0 1
0 1 0 0
0 1 1 1""",

"""0 1 0 1 0 0
0 1 1 1 1 0
1 1 1 1 0 0
1 1 1 1 1 0
0 0 1 1 0 0""",

"""0 1 1 1
1 1 1 0"""
]

func _ready() -> void:
	
	var puzzle_string = test_puzzles.pick_random()
	var puzzle = Puzzle.new(puzzle_string)
	
	puzzle_controller.init(camera, puzzle)
	
