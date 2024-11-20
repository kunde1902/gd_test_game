extends Control

func _ready() -> void:
	$VBoxContainer/Optiones.grab_focus()
	
func _on_optiones_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
	
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
