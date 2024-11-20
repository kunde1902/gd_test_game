extends Sprite2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.has_method("take_damage")):
		if (body == self):
			return
		else:
			if (body.damage_flag == 0):
				body.min_dmg += 2
				body.max_dmg += 2
				queue_free()
			else:
				return	
