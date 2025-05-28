extends Control

@onready var settings_button: Button = $VBoxContainer/SettingsButton

func _ready() -> void:
	settings_button.pressed.connect(func():
		SettingsMenu.show_menu()
	)
