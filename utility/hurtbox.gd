extends Area2D

@export_enum("Cooldown","HurtOnce","DisableHitbox") var HurtBoxType : int = 0

@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var disableTimer : Timer = $DisableTimer

signal hurt(damage : int)

func _on_area_entered(area: Area2D) -> void:
	if (area.is_in_group("attack")):
		if (! area.get("damage") == null):
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set","disabled",true)
					disableTimer.start()
				1: #HitOnce
					pass
				2: #DisableHitbox
					if (area.has_method("tempdisable")):
						area.tempdisable()
			var damage : int = area.damage
			emit_signal("hurt",damage)

func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set","disabled",false)
