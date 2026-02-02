extends Control

var cards := []

func _ready():
	var container = $VBoxContainer/ScrollContainer/MarginContainer/GridContainer

	update_ui(GameData.current_skin)

	var delay_step := 0.05
	var i := 0

	for id in GameData.skins.keys():
		var data = GameData.skins[id]

		var card = preload("res://scene/game/skin_shop/skin_card.tscn").instantiate()
		card.setup(id, data)
		card.clicked.connect(update_ui)
		container.add_child(card)
		
		cards.append(card)  # <- сохраняем

		# эффект появления
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
	var data = GameData.skins[id]
	$VBoxContainer/PreviewPanel/Name.text = data.name
	$VBoxContainer/PreviewPanel/Description.text = "Speed: " + str(data.speed) \
	+ "\nHP Bonus: " + str(data.hp_bonus) + "\nFreeze Protect: " + str(data.max_freeze_stage)
	
	var anim = data.animation_name
	var path = "res://aaasets/players/%s_player/%s_player_fly5.png" % [anim, anim]
	$VBoxContainer/PreviewPanel/SkinSprite.texture = load(path)
	
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
