extends Node2D

@export var spawns : Array[Spawn_info] = []

var time : int = 0
var player : CharacterBody2D = GameManager.player_instance # pegar jogador do GM

func _ready() -> void:
	pass
		
func _on_timer_timeout() -> void:
	if (player != null):
		time += 1
		var enemy_spawns : Array[Spawn_info] = spawns
		for i : Resource in enemy_spawns:
			if (time >= i.time_start && time <= i.time_end):
				if (i.spawn_delay_counter < i.enemy_spawn_delay):
					i.spawn_delay_counter += 1
				else:
					i.spawn_delay_counter = 0
					var new_enemy : Resource = load(str(i.enemy.resource_path))
					var counter : int = 0
					while (counter < i.enemy_num):
						var enemy_spawn : Node = new_enemy.instantiate()
						enemy_spawn.global_position = get_random_position()
						add_child(enemy_spawn)
						counter += 1

func get_random_position() -> Vector2:
	var vpr : Vector2 = get_viewport_rect().size * randf_range(1.1,1.4)
	var top_left : Vector2 = Vector2(player.get_global_position().x - vpr.x/2,
	player.get_global_position().y - vpr.y/2)
	var top_right : Vector2 = Vector2(player.get_global_position().x + vpr.x/2,
	player.get_global_position().y - vpr.y/2)
	var bottom_left : Vector2 = Vector2(player.get_global_position().x - vpr.x/2,
	player.get_global_position().y + vpr.y/2)
	var bottom_right : Vector2 = Vector2(player.get_global_position().x + vpr.x/2,
	player.get_global_position().y + vpr.y/2)
	var pos_side : String = ["up","down","right","left"].pick_random()
	var spawn_pos1 : Vector2 = Vector2.ZERO
	var spawn_pos2 : Vector2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	
	var x_spawn : float = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn : float = randf_range(spawn_pos1.y, spawn_pos2.y)
	
	return Vector2(x_spawn,y_spawn)
