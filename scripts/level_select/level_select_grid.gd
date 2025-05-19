extends GridContainer

@export var level_select_button: PackedScene

@export var levels: Array[PackedScene]

func _ready() -> void:
	
	for level in levels:
		var new_level_button = level_select_button.instantiate()
		add_child(new_level_button)
		new_level_button.init(level)
