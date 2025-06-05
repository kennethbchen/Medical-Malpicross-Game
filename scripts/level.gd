extends Node3D

@export var level_name: String = "Level Name"
@export var solution_image: Texture

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
@onready var settings_button: Button = $PauseMenu/ContentPanel/VBoxContainer/SettingsButon
@onready var resume_button: Button = $PauseMenu/ContentPanel/VBoxContainer/ResumeButton

@onready var win_screen: CanvasLayer = $WinScreen
@onready var win_exit_button: Button = $WinScreen/ExitLevelButton

@onready var level_name_label: Label = $WinScreen/LevelNameContainer/HBoxContainer/LevelNameLabel

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
	
	var puzzle_string = test_puzzles[-1]
	
	puzzle = Puzzle.new(puzzle_string)
	
	puzzle_controller.init(camera, puzzle, solution_image)
	
	wiggle_shader_controller.init(puzzle)
	scream_controller.init(puzzle)
	world_environment.init(puzzle)
	blood_splatter_vignette.init(puzzle)
	
	
	# UI
	
	open_menu_button.pressed.connect(func():
		pause_menu.show()
	)
	
	exit_button.pressed.connect(_exit_level)
	
	restart_button.pressed.connect(_restart_level)
	
	resume_button.pressed.connect(func():
		pause_menu.hide()
		)
	
	settings_button.pressed.connect(SettingsMenu.show_menu)
	
	puzzle_controller.puzzle_solved.connect(_on_puzzle_solved)
	
	win_exit_button.pressed.connect(_exit_level)
	win_screen.hide()
	
	level_name_label.text = level_name

func _exit_level() -> void:
	# Load file instead of from Packed Scene to avoid circular dependency (?)
	get_tree().change_scene_to_file("res://scenes/level_select/level_select.tscn")

func _restart_level() -> void:
	get_tree().reload_current_scene()

func _on_puzzle_solved() -> void:
	EventBus.level_completed.emit()
	SettingsMenu.hide_menu()
	pause_menu.hide()
	win_screen.show()
