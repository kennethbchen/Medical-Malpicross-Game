extends Node

@export var levels: Array[PackedScene]

var level_complete: Array[bool]

# Audio Settings

var master_volume_level: float = 0.75:
	set(value):
		master_volume_level = clamp(value, 0.0, 1.0)
		
		if master_volume_level != 0.0:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), remap(master_volume_level, 0, 1, -30, 10))
		else:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -60)

var sfx_volume_level: float = 0.75:
	set(value):
		sfx_volume_level = clamp(value, 0.0, 1.0)
		
		if sfx_volume_level != 0.0:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), remap(sfx_volume_level, 0, 1, -30, 10))
		else:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), -60)



var voice_volume_level: float = 0.75:
	set(value):
		voice_volume_level = clamp(value, 0.0, 1.0)
		
		if voice_volume_level != 0.0:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"), remap(voice_volume_level, 0, 1, -30, 10))
		else:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"), -60)



# Visual Effect Settings

var camera_shake_intensity: float = 1
var color_effect_intensity: float = 1

func _ready() -> void:
	
	# Trigger setters
	master_volume_level = master_volume_level
	sfx_volume_level = sfx_volume_level
	voice_volume_level = voice_volume_level
	
	level_complete.resize(len(levels))
	level_complete.fill(false)
