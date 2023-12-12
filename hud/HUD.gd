extends CanvasLayer

signal start_game
signal end_game

func show_message(text: String):
	$Message.text = text
	$Message.show()
	$StartButton.show()
	$TutorialButton.show()
	
func show_game_over():
	show_message('Game Over!')
	await $MessageTimer.timeout
	
	$Message.text = "Start a new game!"
	$Message.show()
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	$TutorialButton.show()
	
func update_score(score: int):
	$ScoreLabel.text = "Score: " + str(score)
	
func update_taco_count(count: int):
	$TacoCountLabel.text = "x" + str(count)
	


func _on_message_timer_timeout():
	$Message.hide()


func _on_start_button_pressed():
	_hide_elements()
	start_game.emit(false)
	
func _hide_elements():
	$StartButton.hide()
	$TutorialButton.hide()
	$Message.hide()
	
func _start_with_tutorial():
	_hide_elements()
	start_game.emit(true)


func _on_end_button_pressed():
	end_game.emit()
