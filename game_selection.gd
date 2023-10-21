extends Node
@export var bug_squasher_scene: PackedScene

var currentGame


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func game_complete():
	# I think if you don't disconnect here, you'll get a memory leak
	# that at least is what I was seeing until I put this in
	currentGame.game_complete.disconnect(game_complete)
	remove_child(currentGame)
	$bug_squash_start.show()

func _on_button_pressed():
	var bug_squash = bug_squasher_scene.instantiate()
	currentGame = bug_squash
	add_child(bug_squash)
	$bug_squash_start.hide()
	var signals = bug_squash.get_signal_list()
	#TODO, see if some kind of interface exists for this
	bug_squash.game_complete.connect(game_complete)


