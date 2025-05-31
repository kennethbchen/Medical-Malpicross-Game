extends Control

var level_scene: PackedScene

var level_index: int = -1

@onready var button = $Button

func _ready() -> void:
	button.pressed.connect(_load_level)

func init(level_scene, level_index) -> void:
	self.level_scene = level_scene
	self.level_index = level_index

func _load_level() -> void:
	get_tree().change_scene_to_packed(level_scene)
	EventBus.level_selected.emit(level_index)
