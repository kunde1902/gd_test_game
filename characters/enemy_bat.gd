extends CharacterBody2D

enum BAT_STATE { IDLE, WALK }

@export var move_speed : float = 50

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var sprite : Sprite2D = $Sprite2D
@onready var timer : Timer = $Timer

var move_direction : Vector2 = Vector2.ZERO
var current_state : BAT_STATE = BAT_STATE.IDLE

func _ready() -> void:
	pick_new_state()
	
func _physics_process(_delta : float) -> void:
	if (current_state == BAT_STATE.WALK):
		velocity = move_direction * move_speed
		move_and_slide()
		
func select_new_direction() -> void:
	
	move_direction = Vector2(randi_range(-1,1),randi_range(-1,1)).normalized()
	
	if (move_direction.x < 0):
		sprite.flip_h = true
	elif (move_direction.x > 0):
		sprite.flip_h = false

func pick_new_state() -> void:
	if (current_state == BAT_STATE.IDLE): 
		state_machine.travel("Walk")
		current_state = BAT_STATE.WALK
		select_new_direction()
		timer.start(5)
	elif (current_state == BAT_STATE.WALK):
		state_machine.travel("Idle")
		current_state = BAT_STATE.IDLE
		timer.start(2)
		
func _on_timer_timeout() -> void:
	pick_new_state()
