class_name SimpleMenu
extends Node

@export var actions: Array[SimpleMenuButtonBinding]

func _ready():
	
	for action in actions:
		
		var button = get_node(action.button_path) as Button
		assert(button is Button, "button_path must refer to a button")
		
		if action.calls_on_nodes():
			
			for target_path in action.target_nodes:
				
				var target = get_node(target_path) as Node
				assert(target is Node, "target_node must refer to a node")
				
				if target.has_method(action.method_to_call):
					button.pressed.connect(func(): target.call(action.method_to_call))
					
		elif action.action_type == action.ACTION_TYPE.LOAD_SCENE:
			
			# Load scene is kinda broken because circular references prevents things like
			# pressing a button to go to a scene and pressing another button to go back
			# A solution is probably to input the scene by file name instead of by reference
			assert(action.scene_to_load is String)
			button.pressed.connect(func(): get_tree().change_scene_to_file(action.scene_to_load))
		
		elif action.action_type == action.ACTION_TYPE.RELOAD_CURRENT_SCENE:
			
			button.pressed.connect(func(): get_tree().reload_current_scene())
