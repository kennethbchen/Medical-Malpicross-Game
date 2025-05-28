extends Control

@onready var settings_button: Button = $"Settings Button"

func _ready() -> void:
	settings_button.pressed.connect(func():
		SettingsMenu.show_menu()
	)
