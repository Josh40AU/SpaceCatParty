extends Node

@export var mob_scene: PackedScene
var score

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#new_game()

func new_game():
	get_tree().call_group("bugs", "queue_free")
	score = 0
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
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_player_hit(bodies):
	if !$BugTimer.is_stopped() && bodies.size() > 0:
		player_hit(bodies)
		
			
func player_hit(bodies):
	$KeyboardSoundEffect.play()
	for body in bodies:
		score += 1
		$HUD.update_score(score)
		remove_child(body)


func _on_hud_start_game():
	new_game()
