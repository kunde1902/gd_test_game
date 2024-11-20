extends Area2D

@export var damage : int = 1
@onready var collision : CollisionShape2D = $CollisionShape2DHitbox
@onready var disableTimer : Timer = $DisableHitBoxTimer

func tempdisable() -> void:
	collision.call_deferred("set","disabled",true)
	disableTimer.start()
	
func _on_disable_hit_box_timer_timeout() -> void:
	collision.call_deferred("set","disabled",false)
