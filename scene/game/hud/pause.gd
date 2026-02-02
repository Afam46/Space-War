extends Button

func _on_pressed():
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func pause_game():
	get_tree().paused = true

func resume_game():
	get_tree().paused = false
