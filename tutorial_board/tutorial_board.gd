extends CanvasLayer

signal continue_pressed

func show_message(message: String, picture: String):
	$InstructionLabel.text = message
	$MobSprite.texture = load(picture)


func _on_continue_button_pressed():
	continue_pressed.emit()
