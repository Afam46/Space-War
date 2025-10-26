extends CanvasLayer

signal start_game

func _ready():
	$Restart.hide()

func update_hp(hp):
	$HP.text = str(hp)
	
func update_stage(stage):
	$Stage.text = str(stage)

func show_game_over():
	$Restart.show()

func _on_restart_button_down():
	start_game.emit()
	$Restart.hide()
