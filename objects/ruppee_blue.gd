extends Node2D

var frame : int = 0

func _ready() -> void:
	$AnimationPlayer.play("Idle")
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.has_method("take_damage")):
		if (body == self):
			return
		else:
			if (body.damage_flag == 0):
				body.update_items_global(0,0,0,5)
				queue_free()
			else:
				return
