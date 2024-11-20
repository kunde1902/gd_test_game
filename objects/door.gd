extends Node2D

@export var requires_big_key: bool = false  # Does this door need a big key?
@export var is_locked: bool = false  # Is the door locked initially?

@onready var door_sprite : Sprite2D = $Sprite2D
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var animation : AnimationPlayer = $AnimationPlayer

func interact() -> void:
	if (requires_big_key == true):
		if (GameManager.big_keys > 0):
			GameManager.add_big_keys(-1)
			unlock_door()
	elif (is_locked == true):
		if (GameManager.keys > 0):
			GameManager.add_keys(-1)
			unlock_door()
	else:
		open_door()
	
func unlock_door() -> void:
	is_locked = false
	open_door()

func open_door() -> void:
	animation.play("Open")
	collision_shape.call_deferred("set_disabled", true)
	
