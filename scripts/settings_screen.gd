extends CanvasLayer

@export var master_volume_slider: Slider
@export var sfx_volume_slider: Slider
@export var voice_volume_slider: Slider

@export var screen_shake_slider: Slider
@export var color_effect_slider: Slider

@export var close_button: Button

func _ready() -> void:
	master_volume_slider.value_changed.connect(func(val):
		GameState.master_volume_level = val
	)
	
	sfx_volume_slider.value_changed.connect(func(val):
		GameState.sfx_volume_level = val
	)
	
	voice_volume_slider.value_changed.connect(func(val):
		GameState.voice_volume_level = val
	)
	
	screen_shake_slider.value_changed.connect(func(val):
		GameState.screen_shake_intensity = val
	)
	
	color_effect_slider.value_changed.connect(func(val):
		GameState.color_effect_intensity = val
	)
	
	close_button.pressed.connect(hide_menu)

func show_menu() -> void:
	
	
	master_volume_slider.value = GameState.master_volume_level
	sfx_volume_slider.value = GameState.sfx_volume_level
	voice_volume_slider.value = GameState.voice_volume_level
	
	screen_shake_slider.value = GameState.screen_shake_intensity
	color_effect_slider.value = GameState.color_effect_intensity
	
	show()
	
func hide_menu() -> void:
	hide()
