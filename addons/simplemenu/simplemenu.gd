@tool
extends EditorPlugin

func _enter_tree():
		add_custom_type("SimpleMenu", "Node", preload("simple_menu/simple_menu.gd"), preload("res://addons/simplemenu/simple_menu/SimpleMenu.svg"))

func _exit_tree():
	remove_custom_type("SimpleMenu")
