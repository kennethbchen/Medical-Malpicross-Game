extends Control

var level_scene: PackedScene

@onready var button = $Button

func _ready() -> void:
	button.pressed.connect(_load_level)

func init(level_scene) -> void:
	self.level_scene = level_scene

func _load_level() -> void:
	get_tree().change_scene_to_packed(level_scene)
