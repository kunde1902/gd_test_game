extends TextureRect
# Usado pela hud_global
@export var full_heart_texture : Texture2D
@export var half_heart_texture : Texture2D
@export var empty_heart_texture : Texture2D

func set_heart_state(state: String) -> void:
	match state:
		"full":
			texture = full_heart_texture
		"half":
			texture = half_heart_texture
		"empty":
			texture = empty_heart_texture
