# GameManager.gd (Global singleton script)
extends Node

var characters : Dictionary = { # Dicionario para os bonecos no menu de seleção
	"cat": preload("res://characters/player_cat_2.tscn"),
	"link": preload("res://characters/player_link.tscn")
}

var player_character: PackedScene = null # Copiado pro respawn dos niveis
var player_instance: Node = null  # Cada nivel cria uma instancia do jogador, salva aqui

var lives : int = 3  # Vidas
var max_lives : int = 3
var score : int = 0  # Opcional de score
var respawn_position : Vector2 = Vector2(0, 0) # Guarda o respawn em cada nivel

var keys : int = 0 # itens salvos: chaves, flechas, bombas
var arrows : int = 0 # chaves de chefe, dinheiro
var bombs : int = 0
var ruppees : int = 0
var big_keys : int = 0

func lose_life() -> void: # Chamada pelo jogador quando hp = 0
	lives -= 1
	if lives <= 0:
		game_over()
		
func add_score(score_to_add : int) -> void: # Funções de adicionar coisas
	if (score + score_to_add > 50000):  	# são chamadas pelas entidades
		score = 50000						# e copiadas pela HUD
	else:									# limitados em ABC, conforme necessário
		score += score_to_add
	
func add_ruppees(ruppees_to_add : int) -> void:
	if (ruppees + ruppees_to_add > 999):
		ruppees = 999
	else:
		ruppees += ruppees_to_add
		
func add_keys(keys_to_add : int) -> void:
	if (keys + keys_to_add > 9):
		keys = 9
	else:
		keys += keys_to_add
		
func add_big_keys(big_keys_to_add : int) -> void:
	if (big_keys + big_keys_to_add > 9):
		big_keys = 1
	else:
		big_keys += big_keys_to_add

func add_bombs(bombs_to_add : int) -> void:
	if (bombs + bombs_to_add > 99):
		bombs = 99
	else:
		bombs += bombs_to_add

func add_arrows(arrows_to_add : int) -> void:
	if (arrows + arrows_to_add > 99):
		arrows = 99
	else:
		arrows += arrows_to_add

# Funções encadeadas do game over, call_deferred pra n mexer com a física
func game_over() -> void:
	call_deferred("_reset_game")

func _reset_game() -> void: # resetar o número de vidas, score, etc.
	lives = max_lives
	score = 0
	respawn_position = Vector2(0, 0)
	queue_free()  # Limpar os nodos atuais
	call_deferred("_load_main_menu")
	
func _load_main_menu() -> void: # E finalmente jogar o jogador pro menu
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
