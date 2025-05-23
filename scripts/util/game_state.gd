extends Node

@export var levels: Array[PackedScene]

var level_complete: Array[bool]

# Audio Settings

var sfx_volume_level: float = 1
var ambient_volume_level: float = 1
var voice_volume_level: float = 1

# Visual Effect Settings

var screen_shake_intensity: float = 1
var color_effect_intensity: float = 1

func _ready() -> void:
	
	level_complete.resize(len(levels))
	level_complete.fill(false)
