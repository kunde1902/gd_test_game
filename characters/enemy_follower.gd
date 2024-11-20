extends CharacterBody2D 

@export var move_speed : float = 20
@export var hp : int = 5
@export var min_dmg : int = 1
@export var max_dmg : int = 2

@onready var player : CharacterBody2D = GameManager.player_instance
@onready var HPprogressbar : ProgressBar = $ProgressBar
@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var attack_duration : float = 2
@onready var attack_hitbox : Area2D = $AttackHitBox

var damage_flag : int = 1 # 0 = player, 1 = enemy
var is_attacking : bool = false

var move_direction : Vector2 = Vector2.ZERO
var distance_to_player : Vector2 = Vector2(1000,1000)

func ready() -> void:
	state_machine.travel("Walk")

func _physics_process(_delta : float) -> void:
	pick_new_state()
	move_and_slide()
	
func handle_movement() -> void:
	move_direction = get_global_position().direction_to(player.get_global_position())

	if (move_direction.x < 0):
		sprite.flip_h = true
	elif (move_direction.x >= 0):
		sprite.flip_h = false
		
	velocity = move_direction * move_speed
	
func pick_new_state() -> void:
	if (is_attacking == true):
		return
		
	distance_to_player = get_global_position() - player.get_global_position()
	
	if (distance_to_player.length_squared() > 196):
		state_machine.travel("Walk")
		handle_movement()
	else:
		state_machine.travel("Idle") #Idle = Attack for this creature
		start_attack()
		
func start_attack() -> void:
	is_attacking = true
	animation_tree.set("parameters/Idle/blend_position", Vector2.ZERO)
	
	# Trigger the Attack animation state
	velocity = Vector2.ZERO
	attack()

func attack() -> void:
	attack_hitbox.monitoring = true
	await get_tree().create_timer(attack_duration).timeout 
	attack_hitbox.monitoring = false
	is_attacking = false
	pick_new_state()  # Update to Idle or Walk after attack completes
		
func take_damage(damage : int) -> void:
	hp -= damage
	HPprogressbar.value = hp
	if (hp <= 0):
		GameManager.add_score(100)
		queue_free()
		
func _on_attack_hit_box_body_entered(body: Node2D) -> void:
	if (body.has_method("take_damage")):
		if (body == self):
			return
		else:
			if (body.damage_flag == 0):
				body.take_damage(randi_range(min_dmg,max_dmg))
			else:
				return
