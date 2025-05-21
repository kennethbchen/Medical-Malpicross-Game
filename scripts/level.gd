extends Node3D

@onready var camera: Camera3D = $CameraSystem/CameraShake/Camera3D

@onready var puzzle_controller: Node3D = $PuzzleController

# Puzzle Input Effects

@onready var wiggle_shader_controller: Node = $WiggleShaderController
@onready var scream_controller: AudioStreamPlayer3D = $ScreamController
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var blood_splatter_vignette = $PostProcessing2/BloodSplatterVignette

# UI

@onready var open_menu_button: Button = $GameUI/OpenMenuButton

# Pause Menu

@onready var pause_menu: CanvasLayer = $PauseMenu

@onready var exit_button: Button = $PauseMenu/ContentPanel/VBoxContainer/ExitButton
@onready var restart_button: Button = $PauseMenu/ContentPanel/VBoxContainer/RestartButton
@onready var resume_button: Button = $PauseMenu/ContentPanel/VBoxContainer/ResumeButton


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
	world_environment.init(puzzle)
	blood_splatter_vignette.init(puzzle)
	
	
	# UI
	
	open_menu_button.pressed.connect(func():
		pause_menu.show()
	)
	
	# Load file instead of from Packed Scene to avoid circular dependency (?)
	exit_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/level_select/level_select.tscn")
		)
	
	restart_button.pressed.connect(func():
		get_tree().reload_current_scene()
		)
	
	resume_button.pressed.connect(func():
		pause_menu.hide()
		)
		
	
	
