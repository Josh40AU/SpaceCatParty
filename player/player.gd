extends Area2D
signal hit

@export var speed = 400

var overlapping_objects = []
var screen_size

var power_up_timers = []


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	
func start(pos):
	position = pos
	$AnimatedSprite2D.animation = "on"
	show()
	$CollisionShape2D.disabled = false
	
func _on_body_entered(body):
	overlapping_objects.append(body)
	
func _on_body_exited(body):
	overlapping_objects.erase(body)
	
func power_up(type: String):
	match type:
		"IncreaseSpeed":
			increase_speed()
			create_power_timer(decrease_speed)
		"DecreaseSpeed":
			decrease_speed()
			create_power_timer(increase_speed)

func increase_speed():
	speed += 200
	
func decrease_speed():
	speed -= 200
	
func create_power_timer(del: Callable):
	var timer := Timer.new()
	timer.wait_time = 5
	timer.timeout.connect(del)
	timer.timeout.connect(_remove_timer)
	add_child(timer)
	timer.start()
	power_up_timers.append(timer)

func _remove_timer():
	#FIFO
	var timer = power_up_timers[0]
	power_up_timers.erase(timer)
	timer.queue_free()
	remove_child(timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		#animation = "down"
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		#animation = "up"
		velocity.y -= 1
	if Input.is_action_just_pressed("player_action"):
		hit.emit(overlapping_objects)
	
	
	if(velocity.length() > 0):
		if(!$move_sound.playing):
			$move_sound.play()
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
		$AnimatedSprite2D.animation = "on"
		$AnimatedSprite2D.rotation = velocity.angle() + ( PI / 2)
		$CollisionShape2D.rotation = $AnimatedSprite2D.rotation

	else:
		if($move_sound.playing):
			$move_sound.stop()
		$AnimatedSprite2D.animation = "off"
		$AnimatedSprite2D.stop()
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
