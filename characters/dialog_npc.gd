extends CharacterBody2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var text : Control = $Control

func _ready() -> void:
	$Control.visible = false
	
func interact() -> void:
	$Control.visible = true
	
