extends Control

func _ready() -> void:
	$VBoxContainer/Start.grab_focus()
	
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/character_selection.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/options_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
