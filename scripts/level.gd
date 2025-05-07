extends Node3D

@onready var camera: Camera3D = $CameraSystem/CameraShake/Camera3D

@onready var puzzle_controller: Node3D = $PuzzleController

@onready var wiggle_shader_controller: Node = $WiggleShaderController

@onready var scream_controller: AudioStreamPlayer3D = $ScreamController

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

var puzzle: Puzzle

func _ready() -> void:
	
	var puzzle_string = test_puzzles.pick_random()
	
	puzzle = Puzzle.new(puzzle_string)
	
	puzzle_controller.init(camera, puzzle)
	
	wiggle_shader_controller.init(puzzle)
	scream_controller.init(puzzle)
	
