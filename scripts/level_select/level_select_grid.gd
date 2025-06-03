extends GridContainer

@export var level_select_button: PackedScene

func _ready() -> void:
	
	for i in len(GameState.levels):
		var new_level_button = level_select_button.instantiate()
		add_child(new_level_button)
		new_level_button.init(GameState.levels[i], i, GameState.level_complete[i])
