extends CharacterBody2D

@export var move_speed : float = 100
@export var starting_direction : Vector2 = Vector2(0,1)
@export var respawn_position : Vector2 = Vector2(0, 0)  # Set the respawn position
@export var max_hp : int = 5
@export var hp : int = max_hp

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var HPprogressbar : ProgressBar = $ProgressBar
@onready var attack_duration : float = $AnimationPlayer.get_animation("AttackUp").length # seconds

# State to track if character is currently attacking
var is_player : bool = true
var is_attacking : bool = false
# Track the last movement direction for proper orientation
var last_direction : Vector2 = starting_direction
var attack_hitbox : Rect2 = Rect2(Vector2.ZERO, Vector2(16, 16))  # size of the hitbox

func _ready() -> void:
	update_animation_parameters(starting_direction)
	HPprogressbar.max_value = max_hp
	HPprogressbar.value = hp
	
func _input(event : InputEvent) -> void:
	# Handle attack input and ignore if already attacking
	if (event.is_action_pressed("attack") && is_attacking == false):
		start_attack()

func _physics_process(_delta : float) -> void:
	# Handle movement only if not attacking
	if (is_attacking == false):
		handle_movement()
	move_and_slide()
	
func handle_movement() -> void:
	# Get directional input and normalize
	var input_direction : Vector2 = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"),
	Input.get_action_strength("down") - Input.get_action_strength("up")).normalized()
	if (input_direction != Vector2.ZERO):
		last_direction = input_direction  # Update last direction when moving
	# Update animations and velocity if moving
	update_animation_parameters(input_direction)
	velocity = input_direction * move_speed
	pick_new_state()

func update_animation_parameters(move_input : Vector2) -> void:
	if (move_input != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", move_input)
		animation_tree.set("parameters/Walk/blend_position", move_input)

func pick_new_state() -> void:
	if (is_attacking == true):
		return

	if (velocity != Vector2.ZERO): 
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")
		
func start_attack() -> void:
	is_attacking = true
	animation_tree.set("parameters/Attack/blend_position", last_direction)
	
	# Trigger the Attack animation state
	state_machine.travel("Attack")
	attack()

func attack() -> void:
	velocity = Vector2.ZERO
	print("attack button pressed") #Debug
	# Adjust hitbox position based on direction
	attack_hitbox.position = global_position + (last_direction * 16)
	# Set a timer to deactivate the attack
	await get_tree().create_timer(attack_duration).timeout # Wait for animation duration
	is_attacking = false
	pick_new_state()  # Update to Idle or Walk after attack completes
	
func _on_hurtbox_hurt(damage: Variant) -> void:
	hp -= damage
	HPprogressbar.value = hp
	
	if (hp <= 0 && GameManager.lives > 0):
		respawn()
		GameManager.lose_life()  # Decrease lives
		
func respawn() -> void:
	# Optionally, play a respawn animation here
	# animation_player.play("respawn")  # if you have one
	
	# Reset health to max
	hp = max_hp
	HPprogressbar.value = hp

	# Reset position to respawn point
	position = respawn_position

	# Optional: You might want to reset the state of the character (idle, etc.)
	state_machine.travel("Idle")
	
	# Optional: Add a delay before allowing the character to move again
	await get_tree().create_timer(1.0).timeout  # Respawn delay (if needed)

	# Optionally: Invincibility period (if you want to prevent damage immediately after respawn)
	# set_invincible(true)
	# yield(get_tree().create_timer(2.0), "timeout")  # Example invincibility time
	# set_invincible(false)
	
	# Play idle or default animation after respawn
	#play_idle_animation()

# Optionally add an invincibility function if you're adding invincibility after respawn
#func set_invincible(is_invincible: bool):
	# Your logic to prevent the character from taking damage during invincibility
	#pass
