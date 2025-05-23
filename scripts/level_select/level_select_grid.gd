extends GridContainer

@export var level_select_button: PackedScene

func _ready() -> void:
	
	for level in GameState.levels:
		var new_level_button = level_select_button.instantiate()
		add_child(new_level_button)
		new_level_button.init(level)
