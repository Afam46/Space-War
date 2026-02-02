extends Control

var cards := []
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	var container = $VBoxContainer/ScrollContainer/MarginContainer/GridContainer
	
	update_equipped_icons()
	update_ui("hot_oil")

	var delay_step := 0.05
	var i := 0

	for id in GameData.rashodniki.keys():
		var data = GameData.rashodniki[id]

		var card = preload("res://scene/game/rashodniki_shop/rashodnik_card.tscn").instantiate()
		card.setup(id, data)
		card.clicked.connect(update_ui)
		card.equip_changed.connect(_on_rashodnik_equipped)
		container.add_child(card)
		
		cards.append(card)
		card.modulate.a = 0.0
		card.scale = Vector2(0.8, 0.8)

		var tw = create_tween()
		tw.tween_interval(i * delay_step)
		tw.tween_property(card, "modulate:a", 1.0, 0.25)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(card, "scale", Vector2.ONE, 0.25)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

		i += 1

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scene/game/shop_lobby/shop_lobby.tscn")

func update_ui(id):
	$VBoxContainer/HBoxContainer/Coins.text = "Монет: " + str(GameData.player_coins)
	var data = GameData.rashodniki[id]
	$VBoxContainer/PreviewPanel/Name.text = data.name
	$VBoxContainer/PreviewPanel/Description.text = data.ability

	var path = "res://aaasets/items/%s_big.png" % [id]
	$VBoxContainer/PreviewPanel/SkinSprite.texture = load(path)
	
	update_equipped_icons()
	animate_preview()
	
	for c in cards:
		c.update_state()

func animate_preview():
	var panel = $VBoxContainer/PreviewPanel

	panel.modulate.a = 0.0

	var tw = create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.25)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

func update_equipped_icons():
	$VBoxContainer/HBoxContainer2/ColorRect1.custom_minimum_size = Vector2(162,162)
	$VBoxContainer/HBoxContainer2/ColorRect2.custom_minimum_size = Vector2(162,162)
	$VBoxContainer/HBoxContainer2/ColorRect3.custom_minimum_size = Vector2(162,162)
	var equipped = GameData.get_equipped_rashodniki()

	var slots = [
		$VBoxContainer/HBoxContainer2/ColorRect1/Slot1,
		$VBoxContainer/HBoxContainer2/ColorRect2/Slot2,
		$VBoxContainer/HBoxContainer2/ColorRect3/Slot3
	]
	
	var quantity_slots = [
		$VBoxContainer/HBoxContainer2/ColorRect1/QuantitySlot1,
		$VBoxContainer/HBoxContainer2/ColorRect2/QuantitySlot2,
		$VBoxContainer/HBoxContainer2/ColorRect3/QuantitySlot3
	]

	for i in 3:
		if i < equipped.size():
			var id = equipped[i]
			var icon_path = "res://aaasets/items/%s_small.png" % [id]
			slots[i].texture = load(icon_path)
			quantity_slots[i].text = str(GameData.rashodniki[id].quantity)
		else:
			slots[i].texture = null
			quantity_slots[i].text = ""

func _on_rashodnik_equipped(_id):
	update_equipped_icons()
