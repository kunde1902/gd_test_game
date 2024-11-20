extends CharacterBody2D
# Player que ataca e interage com objetos
@export var move_speed : float = 100
@export var starting_direction : Vector2 = Vector2(0,1)
@export var max_hp : int = 6 # Obs: corações na HUD = max_hp / 2
@export var hp : int = max_hp

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var attack_duration : float = $AnimationPlayer.get_animation("AttackDown").length # seconds
@onready var attack_hitbox : Area2D = $AttackHitBox
@onready var hud : HudGlobal = $HudGlobal

# Algumas bandeiras
var damage_flag : int = 0 # 0 = player, 1 = inimigo
var is_attacking : bool = false

var input_direction : Vector2 = Vector2.ZERO
var attack_direction : Vector2 = starting_direction
var last_input_direction : Vector2 = Vector2.ZERO

var min_dmg : int = 1
var max_dmg : int = 3

func _ready() -> void:
	update_animation_parameters(starting_direction)
	hud.setup_hearts(max_hp/2) # Obs.: 20 corações = 40 max_hp / 2
	hud.update_health(hp)
	
func _input(event : InputEvent) -> void:	
	# Botões pressionados, ignorar se a bandeira estiver true
	if (event.is_action_pressed("attack") && is_attacking == false):
		start_attack()
	elif (event.is_action_pressed("interact") && is_attacking == false):
		interact()
		
func _physics_process(_delta : float) -> void:
	# Mover somente se não estiver atacando
	if (is_attacking == false):
		handle_movement()
	move_and_slide() # Obs.: se essa função estiver dentro do if, toda
	# física é desligada e o player vai ficar 100% imóvel
func handle_movement() -> void:
	# pegar direção e normalizar diagonais
	input_direction = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"),
	Input.get_action_strength("down") - Input.get_action_strength("up")).normalized()
	
	if (input_direction != Vector2.ZERO):	# Salvar last_direction para a hitbox
		attack_direction = input_direction	# de ataque e interação
		
	if (last_input_direction == Vector2.ZERO || last_input_direction.dot(input_direction) <= 0):
		last_input_direction = input_direction # A animação segue o primeiro direcional apertado
		# Ex.: cima + direita, animação cima. direita + cima, animação direita
	update_animation_parameters(last_input_direction)
		
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
	animation_tree.set("parameters/Attack/blend_position", attack_direction)
	
	# Mudar maquina de estados pra Atk
	velocity = Vector2.ZERO
	state_machine.travel("Attack")
	attack()

func attack() -> void:
	# ajustar e ligar a attack box
	attack_hitbox.position = 16 * attack_direction
	attack_hitbox.monitoring = true
	# Timer duração = animação
	await get_tree().create_timer(attack_duration).timeout # Esperar tempo da anim
	is_attacking = false
	attack_hitbox.monitoring = false
	pick_new_state()  # Mudar maquina de estados pra walk ou idle
	
func interact() -> void: # Reusa attack box pra interações
	attack_hitbox.position = 16 * attack_direction
	attack_hitbox.monitoring = true
	await get_tree().create_timer(0.1).timeout # 0.1 seg?
	attack_hitbox.monitoring = false
	pick_new_state()  # Maquina de estados de novo pra idle ou walk
	
func take_damage(damage : int) -> void:
	hp -= damage
	hud.update_health(hp)
	
	if (hp <= 0 && GameManager.lives > 0):
		respawn()
		GameManager.lose_life()  # Chamar global pra diminuir vidas
		
func update_items_hud(a : int,b : int,k : int,r : int) -> void:
	hud.update_arrows(a) # não mexer nessa função diretamente
	hud.update_bombs(b)	# usar update_items_global pra atualizar o GameManager junto
	hud.update_keys(k)
	hud.update_ruppees(r)
	hud.setup_hearts(max_hp/2) # Atualizar corações tb
	hud.update_health(hp)

func update_items_global(a : int,b : int,k : int,r : int) -> void:
	GameManager.add_arrows(a) # chamar essa função qnd pegar ou usar itens
	GameManager.add_bombs(b) # dinheiro, chaves, abrir portas, etc.
	GameManager.add_keys(k)
	GameManager.add_ruppees(r)
	update_items_hud(a,b,k,r)

func respawn() -> void:
	hp = max_hp
	hud.setup_hearts(max_hp/2)
	hud.update_health(hp)

	position = GameManager.respawn_position # Pegar posição do global

	state_machine.travel("Idle")

	await get_tree().create_timer(1.0).timeout  # Delay do respawn
	
func _on_attack_hit_box_body_entered(body: Node2D) -> void:
	# Verificar se é inimigo
	if (is_attacking == true):
		if (body.has_method("take_damage")):
			if (body == self): 	# Crashando se a hitbox colide com ele mesmo
				return			# sem essa verificação
			else:
				if (body.damage_flag == 1): # 1 = inimigo
					body.take_damage(randf_range(min_dmg,max_dmg))
				else:
					return
	# Ver interações com portas	
	elif (is_attacking == false):	
		if (body.has_method("interact")):
			body.interact()
			update_items_global(0,0,0,0) # Chamar pra atualizar nr de chaves
		else:
			return
