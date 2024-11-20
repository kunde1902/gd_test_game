extends CharacterBody2D
#Copy of Player cat, no automatic attack
@export var move_speed : float = 100
@export var starting_direction : Vector2 = Vector2(0,1)
@export var respawn_position : Vector2 = Vector2(0, 0)  # Set the respawn position
@export var max_hp : int = 38
@export var hp : int = max_hp

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var HPprogressbar : ProgressBar = $ProgressBar
@onready var attack_duration : float = $AnimationPlayer.get_animation("AttackUp").length # seconds
@onready var attack_hitbox : Area2D = $AttackHitBox
@onready var hud : HudGlobal = $HudGlobal

# State to track if character is currently attacking
var damage_flag : int = 0 # 0 = player, 1 = enemy
var is_attacking : bool = false
# Track the last movement direction for proper orientation
var last_direction : Vector2 = starting_direction
#var attack_hitbox = Rect2(Vector2.ZERO, Vector2(16, 16))  # size of the hitbox
var min_dmg : int = 1
var max_dmg : int = 5

func _ready() -> void:
	update_animation_parameters(starting_direction)
	HPprogressbar.max_value = max_hp
	HPprogressbar.value = hp
	hud.setup_hearts(max_hp/2) # remember we're using ints, 20 hearts = 40 hp
	hud.update_health(hp)
	
func _input(event : InputEvent) -> void:
	# Handle attack input and ignore if already attacking
	if (event.is_action_pressed("attack") && is_attacking == false):
		start_attack()
	elif (event.is_action_pressed("interact") && is_attacking == false):
		interact()
		
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
	velocity = Vector2.ZERO
	state_machine.travel("Attack")
	attack()

func attack() -> void:
	# Adjust hitbox position based on direction
	attack_hitbox.position = 16 * last_direction
	attack_hitbox.monitoring = true
	# Set a timer to deactivate the attack
	await get_tree().create_timer(attack_duration).timeout # Wait for animation duration
	is_attacking = false
	attack_hitbox.monitoring = false
	pick_new_state()  # Update to Idle or Walk after attack completes
	
func interact() -> void: #reuse hitbox from attack to interact with items/doors
	attack_hitbox.position = 16 * last_direction
	attack_hitbox.monitoring = true
	await get_tree().create_timer(0.1).timeout # Wait for animation duration
	attack_hitbox.monitoring = false
	pick_new_state()  # Update to Idle or Walk
	
func take_damage(damage : int) -> void:
	hp -= damage
	HPprogressbar.value = hp
	hud.update_health(hp)
	
	if (hp <= 0 && GameManager.lives > 0):
		respawn()
		GameManager.lose_life()  # Decrease lives
		
func update_items_hud(a : int,b : int,k : int,r : int) -> void: # don't call this directly
	hud.update_arrows(a)
	hud.update_bombs(b)
	hud.update_keys(k)
	hud.update_ruppees(r)
	hud.setup_hearts(max_hp/2) # for heart containers
	hud.update_health(hp)

func update_items_global(a : int,b : int,k : int,r : int) -> void: # call this when items are picked or used
	GameManager.add_arrows(a)
	GameManager.add_bombs(b)
	GameManager.add_keys(k)
	GameManager.add_ruppees(r)
	update_items_hud(a,b,k,r)

func respawn() -> void:
	hp = max_hp
	HPprogressbar.value = hp
	hud.setup_hearts(max_hp/2)
	hud.update_health(hp)

	position = respawn_position

	state_machine.travel("Idle")

	await get_tree().create_timer(1.0).timeout  # Respawn delay (if needed)
	
func _on_attack_hit_box_body_entered(body: Node2D) -> void:
	#check for attacks
	if (is_attacking == true):
		if (body.has_method("take_damage")):
			if (body == self): # crashes if removed
				return
			else:
				if (body.damage_flag == 1):
					body.take_damage(randf_range(min_dmg,max_dmg))
				else:
					return
	#check for doors	
	elif (is_attacking == false):	
		if (body.has_method("interact")):
			body.interact()
			update_items_global(0,0,0,0) #call this to update the hud when keys are used
		else:
			return
