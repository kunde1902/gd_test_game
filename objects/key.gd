extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.has_method("take_damage")):
		if (body == self):
			return
		else:
			if (body.damage_flag == 0):
				body.update_items_global(0,0,1,0)
				queue_free()
			else:
				return
