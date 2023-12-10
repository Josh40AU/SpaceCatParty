extends RigidBody2D

var changed = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play('walk')
	$DirectionTimer.start()
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _change_direction():
	var direction = linear_velocity.angle()
	direction += randf_range(-PI, PI)

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 350.0), 0.0)
	linear_velocity = velocity.rotated(direction)
	# not sure why this is needed, but, I think it's because the
	# animated sprite's direction can be different thant he whole
	# bug
	$AnimatedSprite2D.rotation = direction + ( PI / 2 ) - rotation

	
func pause_bug():
	linear_velocity = Vector2.ZERO
	var timer = Timer.new()
	timer.wait_time = 5
	timer.timeout.connect(_change_direction)
	add_child(timer)
	timer.start()
	
func get_mob_type():
	return "Bug"


func _on_direction_timer_timeout():
	var random = randi_range(1, 3)
	if random > 1 && !changed:
		_change_direction()
		changed = true
