extends Node2D

class_name HudGlobal

@export var heart_scene : PackedScene
@onready var container : GridContainer = $Base/HeartContainer

#ruppees
@onready var hundreds_sprite : Sprite2D = $Base/RuppeeContainer/RuppeeSpriteCent
@onready var tens_sprite : Sprite2D = $Base/RuppeeContainer/RuppeeSpriteDecimal
@onready var units_sprite : Sprite2D = $Base/RuppeeContainer/RuppeeSpriteUnit

#bombs
@onready var tens_sprite2 : Sprite2D = $Base/BombContainer/BombSpriteDecimal
@onready var units_sprite2 : Sprite2D = $Base/BombContainer/BombSpriteUnit

#arrows
@onready var tens_sprite3 : Sprite2D = $Base/ArrowContainer/ArrowSpriteDecimal
@onready var units_sprite3 : Sprite2D = $Base/ArrowContainer/ArrowSpriteUnit

#keys
@onready var units_sprite4 : Sprite2D = $Base/KeyContainer/KeySprite

var hearts : Array = []

func setup_hearts(max_hearts : int) -> void:
	# Clear existing hearts
	for heart : Node in hearts:
		heart.queue_free()
	hearts.clear()

	# Create the new hearts
	for i : int in range(max_hearts):
		var heart : Node = heart_scene.instantiate()
		container.add_child(heart)
		hearts.append(heart)

func update_health(health : int) -> void: #, max_health : int
	for i : int in range(hearts.size()):
		if health > i * 2:
			hearts[i].set_heart_state("full")
		elif health == i * 2:
			hearts[i].set_heart_state("half")
		else:
			hearts[i].set_heart_state("empty")

func update_ruppees(ruppees : int) -> void:
	hundreds_sprite.frame = (GameManager.ruppees / 100 ) % 10
	tens_sprite.frame = (GameManager.ruppees / 10 ) % 10
	units_sprite.frame = GameManager.ruppees % 10
	
func update_bombs(bombs : int) -> void:
	tens_sprite2.frame = (GameManager.bombs / 10) % 10
	units_sprite2.frame = GameManager.bombs % 10
	
func update_arrows(arrows : int) -> void:
	tens_sprite3.frame = (GameManager.arrows / 10) % 10
	units_sprite3.frame = GameManager.arrows % 10

func update_keys(keys : int) -> void:
	units_sprite4.frame = GameManager.keys % 10
