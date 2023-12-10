extends CanvasLayer

signal start_game
signal end_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message('Game Over!')
	await $MessageTimer.timeout
	
	$Message.text = "Use WASD to move\nand 'Space' to hit the bugs!"
	$Message.show()
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	$EndButton.show()
	
func update_score(score: int):
	$ScoreLabel.text = str(score)
	
func update_taco_count(count: int):
	$TacoCountLabel.text = "x" + str(count)
	


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_message_timer_timeout():
	$Message.hide()


func _on_start_button_pressed():
	$StartButton.hide()
	$EndButton.hide()
	start_game.emit()
	$Message.hide()


func _on_end_button_pressed():
	end_game.emit()
