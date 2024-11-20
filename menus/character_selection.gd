extends Control

func _ready() -> void:
	$"VBoxContainer/Play as Cat".grab_focus()

func _on_play_as_cat_pressed() -> void:
	GameManager.player_character = GameManager.characters["cat"]
	get_tree().change_scene_to_file("res://levels/game_level1.tscn")

func _on_play_as_link_pressed() -> void:
	GameManager.player_character = GameManager.characters["link"]
	get_tree().change_scene_to_file("res://levels/game_level1.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
