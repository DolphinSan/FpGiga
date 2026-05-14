extends AudioStreamPlayer

func _ready():
	# Connect the finished signal to yourself
	finished.connect(_on_finished)
	playing == true

func _on_finished():
	# Restart the audio when it ends
	play()
