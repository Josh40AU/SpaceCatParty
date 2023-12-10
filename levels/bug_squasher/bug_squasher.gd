extends Node
signal game_complete

@export var mob_scene: PackedScene
@export var coffee_scene: PackedScene
@export var business_person_scene: PackedScene
var score


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _get_random_position() -> Vector2:
	# max numbers from project settings
	var x = randi_range(0, 1152)
	var y = randi_range(0, 648)
	return Vector2(x, y)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.hide()
	pass
	#new_game()

func new_game():
	get_tree().call_group("bugs", "queue_free")
	score = 0
	$Player.show()
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)


func _on_start_timer_timeout():
	$BugTimer.start()
	$EndTimer.start()

func _on_end_timer_timeout():
	$BugTimer.stop()
	$HUD.show_game_over()


func _on_bug_timer_timeout():
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	var position = mob_spawn_location.position
	var direction = mob_spawn_location.rotation + PI / 2
	# add some randomness to the direction
	direction += randf_range(-PI / 4, PI / 4)
	_spawn_bug(position, direction)
	
func _spawn_bug(position: Vector2, direction: float):
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	mob.position = position
	mob.rotation = direction + ( PI / 2)

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 350.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_player_hit(bodies):
	if !$BugTimer.is_stopped() && bodies.size() > 0:
		player_hit(bodies)
		
			
func player_hit(bodies):
	for body in bodies:
		var mob_type = body.get_mob_type()
		# I wanted some of these interactions to be defined
		# at the mob level, but audio doesn't play there for
		# some reason
		match mob_type:
			"Coffee":
				$sound_effect.stream = load("res://assets/audio/drink.wav")
				$sound_effect.play()
				$Player.power_up("IncreaseSpeed")
			"BusinessPerson":
				$sound_effect.stream = load("res://assets/audio/hang_up.wav")
				$sound_effect.play()
				_business_person_bug_spawn(body.position)
			"Bug":
				score += 1
				$HUD.update_score(score)
				$sound_effect.stream = load("res://assets/audio/shock.wav")
				$sound_effect.play()
		remove_child(body)

func _business_person_bug_spawn(location: Vector2):
	var bug_number = randi_range(3, 8)
	for i in bug_number:
		var direction = randf_range(0, 2 * PI)
		var random_position_offset = Vector2(randi_range(5, 10), randi_range(5, 10))
		_spawn_bug(location + random_position_offset, direction)

func _business_person_missed():
	$Player.power_up("DecreaseSpeed")
	$sound_effect.stream = load("res://assets/audio/dial_tone.wav")
	$sound_effect.play()

func _on_hud_start_game():
	new_game()


func _on_hud_end_game():
	game_complete.emit()


func _on_power_up_timer_timeout():
	if $BugTimer.is_stopped():
		return
	var random = 3 #randi_range(0, 3)
	if random == 2:
		var coffee = coffee_scene.instantiate()
		coffee.position = _get_random_position()
		add_child(coffee)
	if random == 3:
		var business = business_person_scene.instantiate()
		business.position = _get_random_position()
		add_child(business)
		business.time_expired.connect(_business_person_missed)
		$sound_effect.stream = load("res://assets/audio/phone_ring.wav")
		$sound_effect.play()
	pass # Replace with function body.
