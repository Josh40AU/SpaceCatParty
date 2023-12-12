extends Node
signal game_complete

@export var mob_scene: PackedScene
@export var coffee_scene: PackedScene
@export var business_person_scene: PackedScene
@export var taco_scene: PackedScene
var score: int
var taco_count: int = 0
var show_instructions: bool
var level = -1
var required_spawn: int = -1

	
func _get_random_position() -> Vector2:
	# max numbers from project settings
	var x = randi_range(0, 1152)
	var y = randi_range(0, 648)
	return Vector2(x, y)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.hide()
	
func continue_game():
	$Tutorial.hide()
	level += 1
	if level == 0: 
		new_game()
		return
	
	if level == 4: 
		$HUD.show_game_over()
		level = -1
		return
	required_spawn = level
	new_level()

func new_level():
	$BugTimer.start()
	$EndTimer.start()

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
	print('timer quit' + str(show_instructions))
	if show_instructions:
		_show_level_instructions()
		return
	continue_game()

func _show_level_instructions():
	if level == -1:
		$Tutorial.show_message("You have inherited a space base absolutely riddled with bugs! Use WASD to navigate around and spacebar to zap them. Get rid of as many as you can!", "res://assets/art/BeetleFrame-1-nb.png")
	if level == 0:
		$Tutorial.show_message("Space Tacos are a special item that randomly appear. If you collect 5 of them, all the bugs on screen will freeze for 5 seconds!", "res://assets/art/taco-frame-1.png")
	if level == 1:
		$Tutorial.show_message("Coffee makes you a more effective bug hunter. Collect it to get a speed boost!", "res://assets/art/coffeeFrame-1.png")
	if level == 2:
		$Tutorial.show_message("Clients are tricky. They'll ring you randomly, and if you ignore them you'll end up slowing down, but if you answer, they find a lot of bugs!", "res://assets/art/business-man-sm-frame-1.png")
	if level == 3:
		continue_game()
		return
	$Tutorial.show()

func _on_hud_start_game(instructions: bool):
	print(instructions)
	show_instructions = instructions
	if show_instructions: 
		_show_level_instructions()
		return
	continue_game()

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
		_handle_player_interaction(body)
		

func _handle_player_interaction(body):
	var mob_type = body.get_mob_type()
	# I wanted some of these interactions to be defined
	# at the mob level, but audio doesn't play there for
	# some reason
	match mob_type:
		"Coffee":
			_play_sound_effect("res://assets/audio/drink.wav")
			$Player.power_up("IncreaseSpeed")
		"BusinessPerson":
			_play_sound_effect("res://assets/audio/hang_up.wav")
			_business_person_bug_spawn(body.position)
		"Bug":
			score += 1
			$HUD.update_score(score)
			_play_sound_effect("res://assets/audio/shock.wav")
		"Taco":
			_handle_taco()
	remove_child(body)
	
func _handle_taco():
	_play_sound_effect("res://assets/audio/food_crunch.wav")
	taco_count += 1
	if taco_count == 5:
		get_tree().call_group("bugs", "pause_bug")
		taco_count = 0
	$HUD.update_taco_count(taco_count)

func _business_person_bug_spawn(location: Vector2):
	var bug_number = randi_range(3, 8)
	for i in bug_number:
		var direction = randf_range(0, 2 * PI)
		var random_position_offset = Vector2(randi_range(5, 10), randi_range(5, 10))
		_spawn_bug(location + random_position_offset, direction)

func _business_person_missed():
	$Player.power_up("DecreaseSpeed")
	_play_sound_effect("res://assets/audio/dial_tone.wav")

func _play_sound_effect(sound_name: String):
	var sound_effect = AudioStreamPlayer.new()
	sound_effect.stream = load(sound_name)
	add_child(sound_effect)
	sound_effect.play()
	await sound_effect.finished
	remove_child(sound_effect)

func _on_hud_end_game():
	game_complete.emit()


func _on_power_up_timer_timeout():
	if $BugTimer.is_stopped():
		return
	var random = randi_range(0, 3)
	if required_spawn > 0:
		random = required_spawn
	if random == 1 and level > 0:
		var taco = taco_scene.instantiate()
		taco.position = _get_random_position()
		add_child(taco)
	if random == 2 and level > 1:
		var coffee = coffee_scene.instantiate()
		coffee.position = _get_random_position()
		add_child(coffee)
	if random == 3 and level > 2:
		var business = business_person_scene.instantiate()
		business.position = _get_random_position()
		add_child(business)
		business.time_expired.connect(_business_person_missed)
		_play_sound_effect("res://assets/audio/phone_ring.wav")
	required_spawn = -1
