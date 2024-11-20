extends Node2D
# Usado pela heart_scene, que em seguida entra na hud_global
func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.has_method("update_items_global")):
		if (body == self):
			return
		else:
			if (body.damage_flag == 0):
				body.max_hp += 2
				body.hp = body.max_hp
				body.update_items_global(0,0,0,0)
				queue_free()
			else:
				return
