extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()

func _on_timer_timeout():
	queue_free()
	
func get_mob_type():
	return "Taco"
