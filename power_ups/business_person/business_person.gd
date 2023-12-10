extends RigidBody2D
signal time_expired

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()

func _on_timer_timeout():
	time_expired.emit()
	queue_free()
	
func get_mob_type():
	return "BusinessPerson"
