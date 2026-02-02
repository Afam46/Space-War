extends Control

@onready var coins_label = $MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var upgrade_hp_btn = $MarginContainer/VBoxContainer/VBoxContainer/UpgradeHP
@onready var upgrade_damage_btn = $MarginContainer/VBoxContainer/VBoxContainer/UpgradeDamage
@onready var upgrade_boost_time_btn = $MarginContainer/VBoxContainer/VBoxContainer/UpgradeBoostTime
@onready var hp_info = $MarginContainer/VBoxContainer/VBoxContainer/UpgradeHP/Label
@onready var dm_info = $MarginContainer/VBoxContainer/VBoxContainer/UpgradeDamage/Label
@onready var bt_info = $MarginContainer/VBoxContainer/VBoxContainer/UpgradeBoostTime/Label

func _ready():
	update_ui()

func update_ui():
	coins_label.text = "Монеты: " + str(GameData.player_coins)
	
	upgrade_hp_btn.text = "Увеличить хп\nЦена: " + str(GameData.hp_upgrade_price)
	upgrade_damage_btn.text = "Увеличить урон\nЦена: " + str(GameData.damage_upgrade_price)
	upgrade_boost_time_btn.text = "Увеличить время буста\nЦена: " + str(GameData.boost_time_upgrade_price)
	
	hp_info.text = "HP: " + str(GameData.max_hp)
	dm_info.text = "Урон: " + str(GameData.damage_bonus)
	bt_info.text = "Время буста: " + str(GameData.boost_time)

func attempt_upgrade(price: int, upgrade_type: String) -> bool:
	if GameData.player_coins >= price:
		GameData.player_coins -= price
		return true
	else:
		phone_vibrate(50)
		return false

func upgrade_hp():
	if attempt_upgrade(GameData.hp_upgrade_price, "hp"):
		GameData.max_hp += 150
		GameData.hp_upgrade_price += 1
		update_ui()
		GameData.save_game()

func upgrade_damage():
	if attempt_upgrade(GameData.damage_upgrade_price, "damage"):
		GameData.damage_bonus += 0.5
		GameData.damage_upgrade_price += 1
		update_ui()
		GameData.save_game()

func upgrade_boost_time():
	if attempt_upgrade(GameData.boost_time_upgrade_price, "boost_time"):
		GameData.boost_time += 0.5
		GameData.boost_time_upgrade_price += 200
		update_ui()
		GameData.save_game()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scene/game/main_menu/main_menu.tscn")

func phone_vibrate(intensity := 50):
	if Engine.has_singleton("HapticFeedback"):
		var h = Engine.get_singleton("HapticFeedback")
		h.vibrate(intensity)
	else:
		Input.vibrate_handheld(50)
