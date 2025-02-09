extends Node

func _unhandled_input(event):
	
	if not OS.is_debug_build(): return
	
	if event.is_action_pressed("debug_reload_scene"):
		get_tree().reload_current_scene()
	
	if event.is_action_pressed("debug_quit_game"):
		get_tree().quit()
