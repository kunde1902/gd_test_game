extends Node2D

@onready var player_scene : PackedScene

var respawn_point : Vector2 = Vector2(0,0)
var	player_node_name : String = "null"
var node : Node2D = null
var ref_to_self : Node2D = self

func _ready() -> void:
	get_player_node_name()
	spawn_player()
	set_gamamanger_respawn_pos()
	set_spawner_target()
			
func get_player_node_name() -> void:
	player_scene = GameManager.player_character
	
func spawn_player() -> void:
	if (GameManager.player_instance == null):
		if (player_scene):
			GameManager.player_instance = player_scene.instantiate()
			add_child(GameManager.player_instance)
			GameManager.player_instance.global_position = respawn_point
			player_node_name = GameManager.player_instance.name
	elif (GameManager.player_instance != null):
		add_child(GameManager.player_instance)
		GameManager.player_instance.global_position = respawn_point
		player_node_name = GameManager.player_instance.name
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == player_node_name):
		$Roof.visible = false
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body.name == player_node_name):
		$Roof.visible = true

func _on_area_2d_next_level_body_entered(body: Node2D) -> void:
	if (body.name == player_node_name):
		call_deferred("_change_to_next_level")
		
func _change_to_next_level() -> void:
	GameManager.player_instance.get_parent().remove_child(GameManager.player_instance)
	get_tree().change_scene_to_file("res://levels/game_level2.tscn")
	
func find_node_among_children(node_name: String) -> Node:
	for child : Node2D in ref_to_self.get_children():
		if child.name == node_name:
			return child
	return null  # Return null if no match is found

func set_spawner_target() -> void:
	node = find_node_among_children("EnemySpawner")
	if (node != null):
		node.player = GameManager.player_instance
	elif (node == null):
		print("failed to set spawner target")
		
func set_gamamanger_respawn_pos() -> void:
	GameManager.respawn_position = respawn_point
