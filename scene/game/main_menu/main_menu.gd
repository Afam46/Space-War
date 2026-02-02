extends CanvasLayer

func _ready():
	Background.set_speed(50, 0.6) 
	GameData.load_game()
	if GameData.record_stage:
		$MarginContainer/VBoxContainer/VBoxContainer1/RecordStage.text = "Record: " + str(GameData.record_stage)
	
func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://scene/game/main/main.tscn")

func _on_go_gain_pressed():
	get_tree().change_scene_to_file("res://scene/game/shop_lobby/shop_lobby.tscn")


func _on_button_pressed():
	GameData.clear_save()


func _on_upgrade_pressed():
	get_tree().change_scene_to_file("res://scene/game/upgrade/upgrade.tscn")

func _on_button_50_pressed():
	GameData.start_stg = 50
	$MarginContainer/VBoxContainer/HBoxContainer/Button50.text = "Готово!"

func _on_button_75_pressed():
	GameData.start_stg = 75
	$MarginContainer/VBoxContainer/HBoxContainer/Button75.text = "Готово!"

func _on_button_25_pressed():
	GameData.start_stg = 25
	$MarginContainer/VBoxContainer/HBoxContainer/Button25.text = "Готово!"

func _on_button_1_pressed():
	GameData.start_stg = 1
	$MarginContainer/VBoxContainer/HBoxContainer/Button1.text = "Готово!"
