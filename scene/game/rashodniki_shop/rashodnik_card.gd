extends Control

var rashodnik_id
var screen_size

signal clicked(id)
signal equip_changed(id)

func _ready():
	screen_size = get_viewport_rect().size
	custom_minimum_size = Vector2(screen_size.x / 3.5, screen_size.y / 3)

func setup(id, data):
	rashodnik_id = id
	$MarginContainer/VBoxContainer/ButtonsContainer/BuyButton.modulate = Color(1.0, 1.0, 0.0)
	$MarginContainer/VBoxContainer/RashodnikName.text = data.name
	$MarginContainer/VBoxContainer/Control/Icon.texture = load(data.icon)
	$MarginContainer/VBoxContainer/Price.text = str(data.price) + " Монет"

	update_state()


func update_state():
	var data = GameData.rashodniki[rashodnik_id]
	
	var buy_button = $MarginContainer/VBoxContainer/ButtonsContainer/BuyButton
	
	if data.locked:
		buy_button.hide()
		$MarginContainer/VBoxContainer/Control/Icon.modulate = Color(0.0, 0.0, 0.0, 1.0)
		$MarginContainer/VBoxContainer/RashodnikName.hide()
		$MarginContainer/VBoxContainer/Price.hide()
		$MarginContainer/VBoxContainer/Control/Block.texture = load("res://aaasets/ui/block.png")
	else:
		buy_button.text = "Купить"
		buy_button.disabled = false

	# --- Кнопка "Выбрать" ---
	var equip_button = $MarginContainer/VBoxContainer/ButtonsContainer/EquipButton

	if data.equiped:
		equip_button.text = "Снять (%s)" % [data.quantity]
		equip_button.modulate = Color(1.0, 1.5, 0.0)
		equip_button.disabled = false
	else:
		equip_button.text = "Выбрать (%s)" % [data.quantity]
		equip_button.modulate = Color(0.0, 1.0, 0.0)
		equip_button.disabled = false
	
	if data.locked:
		equip_button.hide()

func _on_BuyButton_pressed():
	var data = GameData.rashodniki[rashodnik_id]

	if GameData.player_coins >= data.price:
		GameData.player_coins -= data.price
		data.quantity += 1
		GameData.save_game()

		update_state()
		emit_signal("clicked", rashodnik_id)
	else:
		print("Не хватает монет")


func _on_EquipButton_pressed():
	var data = GameData.rashodniki[rashodnik_id]

	if data.equiped:
		data.equiped = false
		data.equiped_priority = 0
		GameData.save_game()
		update_state()
		emit_signal("equip_changed", rashodnik_id)
		return

	if GameData.get_equipped_rashodniki().size() >= 3:
		GameData.rashodniki[GameData.get_equipped_rashodniki()[2]].equiped = false

	data.equiped = true
	GameData.current_max_equiped_priority += 1
	data.equiped_priority = GameData.current_max_equiped_priority
	GameData.save_game()
	update_state()
	emit_signal("equip_changed", rashodnik_id)


func _on_rashodnik_card_pressed():
	var data = GameData.rashodniki[rashodnik_id]
	
	if data.locked == false:
		emit_signal("clicked", rashodnik_id)
