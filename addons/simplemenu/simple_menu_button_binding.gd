@tool
class_name SimpleMenuButtonBinding
extends Resource



enum ACTION_TYPE {
	HIDE, ## Call hide() on all target_nodes.
	SHOW, ## Call show() on all target_nodes.
	CUSTOM_METHOD, ## Call a custom method on all target nodes indicated by method_to_call.
	LOAD_SCENE, ## Load a scene indicated by scene_to_load.
	RELOAD_CURRENT_SCENE, ## Reloads curren scene.
	
	}

# NodePath instead of Node is a workaround to the fact that Node doesn't work

## The button that will initiate this action
@export var button_path: NodePath

## The method that will be called on target_nodes.
@export var action_type: ACTION_TYPE = ACTION_TYPE.HIDE: set = _set_action_type

## The method that all target_nodes will call
var method_to_call: String: get = _get_method_to_call

## The scene that will be loaded
var scene_to_load: String

## The nodes that will call the method indicated by action_type
var target_nodes: Array[NodePath]

func _set_action_type(new_action: ACTION_TYPE):
	action_type = new_action
	notify_property_list_changed()

func _get_method_to_call() -> String:
	match(action_type):
		ACTION_TYPE.HIDE:
			return "hide"
		ACTION_TYPE.SHOW:
			return "show"
		_:
			return method_to_call

func calls_on_nodes() -> bool:
	return action_type == ACTION_TYPE.HIDE or \
			action_type == ACTION_TYPE.SHOW or \
			action_type == ACTION_TYPE.CUSTOM_METHOD

func _get_property_list() -> Array:
	var list = []
	
	if calls_on_nodes():
	
		if action_type == ACTION_TYPE.CUSTOM_METHOD:
			list.push_back({ 
						name = "method_to_call", 
						type = TYPE_STRING
					})
					
		list.push_back({ 
						name = "target_nodes", 
						type = TYPE_ARRAY,
					})
	
	if action_type == ACTION_TYPE.LOAD_SCENE:
		list.push_back({ 
						name = "scene_to_load", 
						type = TYPE_STRING,
					})
			
	
	return list
