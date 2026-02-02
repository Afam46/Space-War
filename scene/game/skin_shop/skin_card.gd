extends Button

var skin_id
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	custom_minimum_size = Vector2(screen_size.x / 3.5, screen_size.y / 3.8)

func setup(id, data):
	$MarginContainer/VBoxContainer/VBoxContainer/Price.text = ''
	skin_id = id
	
	if data.locked == true:
		$MarginContainer/VBoxContainer/Control/Icon.modulate = Color(0,0,0)
		$MarginContainer/VBoxContainer/Control/Block.texture = load("res://aaasets/ui/block.png")
		$MarginContainer/VBoxContainer/VBoxContainer/SkinName.hide()
	else:
		$MarginContainer/VBoxContainer/Control/Icon.texture = load(data.icon)
		$MarginContainer/VBoxContainer/VBoxContainer/SkinName.text = data.name
	
	if data.locked == true:
		$MarginContainer/VBoxContainer/VBoxContainer/Button.hide()
	elif skin_id == GameData.current_skin:
		$MarginContainer/VBoxContainer/VBoxContainer/Button.modulate = Color(0.0, 1.0, 0.0, 1)
		$MarginContainer/VBoxContainer/VBoxContainer/Button.text = "Выбрано"
	elif data.owned:
		$MarginContainer/VBoxContainer/VBoxContainer/Button.modulate = Color(1.0, 0.486, 0.0, 1.0)
		$MarginContainer/VBoxContainer/VBoxContainer/Button.text = "Выбрать"
	else:
		$MarginContainer/VBoxContainer/VBoxContainer/Price.text = str(data.price) + " Монет"
		$MarginContainer/VBoxContainer/VBoxContainer/Button.modulate = Color(1.0, 1.0, 0.0, 1.0)
		$MarginContainer/VBoxContainer/VBoxContainer/Button.text = "Купить"
		
	update_state()

func _on_button_pressed():
	var data = GameData.skins[skin_id]
	
	if data.locked == true:
		return
		
	if not data.owned:
		if GameData.player_coins >= data.price:
			GameData.player_coins -= data.price
			GameData.skins[skin_id].owned = true
			GameData.current_skin = skin_id
			GameData.save_game()
			$MarginContainer/VBoxContainer/VBoxContainer/Price.text = ""
			$MarginContainer/VBoxContainer/VBoxContainer/Button.modulate = Color(0.0, 1.0, 0.0, 1)
			$MarginContainer/VBoxContainer/VBoxContainer/Button.text = "Выбрано"
			emit_signal("clicked", skin_id)
	else:
		GameData.current_skin = skin_id
		GameData.save_game()
		$MarginContainer/VBoxContainer/VBoxContainer/Button.modulate = Color(0.0, 1.0, 0.0, 1)
		$MarginContainer/VBoxContainer/VBoxContainer/Button.text = "Выбрано"
		emit_signal("clicked", skin_id)

signal clicked(skin_id)

func _on_skin_card_pressed():
	var data = GameData.skins[skin_id]
	
	if data.locked == false:
		emit_signal("clicked", skin_id)

func update_state():
	var data = GameData.skins[skin_id]

	if data.locked:
		$MarginContainer/VBoxContainer/VBoxContainer/Button.hide()
		$MarginContainer/VBoxContainer/VBoxContainer/Button.modulate = Color.GRAY
		return

	if skin_id == GameData.current_skin:
		$MarginContainer/VBoxContainer/VBoxContainer/Button.text = "Выбрано"
		$MarginContainer/VBoxContainer/VBoxContainer/Button.modulate = Color(0.0, 1.0, 0.0)
	elif data.owned:
		$MarginContainer/VBoxContainer/VBoxContainer/Button.text = "Выбрать"
		$MarginContainer/VBoxContainer/VBoxContainer/Button.modulate = Color(1.0, 0.5, 0.0)
	else:
		$MarginContainer/VBoxContainer/VBoxContainer/Price.text = str(data.price) + " Монет"
		$MarginContainer/VBoxContainer/VBoxContainer/Button.text = "Купить"
		$MarginContainer/VBoxContainer/VBoxContainer/Button.modulate = Color(1.0, 1.0, 0.0)
