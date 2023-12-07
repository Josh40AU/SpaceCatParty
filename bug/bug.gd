extends RigidBody2D

var changed = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play('walk')
	
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var random = randf_range(0, 180)
	if random > 175 && !changed:
		_change_direction()
		changed = true
	pass
