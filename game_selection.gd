extends Node
@export var bug_squasher_scene: PackedScene

var currentGame

var bg_music := AudioStreamPlayer.new()
# Called when the node enters the scene tree for the first time.

func _ready():
	# initital sound
	bg_music.stream = load("res://assets/audio/musicTheme-opening.wav")
	bg_music.autoplay = true
	bg_music.volume_db = -10.0
	bg_music.finished.connect(_loadMusic)
	add_child(bg_music)
	pass

func _loadMusic():
	# continual music play
	bg_music.stream = load("res://assets/audio/musicTheme-short.wav")
	bg_music.play()
	bg_music.finished.disconnect(_loadMusic)
	bg_music.finished.connect(_replayMusic)
	
func _replayMusic():
	bg_music.play()
	
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


