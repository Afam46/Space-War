extends Control

@onready var grid = $MarginContainer/VBoxContainer/ScrollContainer/CenterContainer/GridContainer
@onready var rand_buy_button = $MarginContainer/VBoxContainer/HBoxContainer2/CenterContainer/RandomBuy
@onready var coins_label = $MarginContainer/VBoxContainer/HBoxContainer/CoinsLabel
@onready var rare_label = $MarginContainer/VBoxContainer/HBoxContainer3/RareLabel

const BOOST_BUTTON_SCENE = preload("res://scene/game/boost_shop/boost_buton/boost_button.tscn")
const RARE_TEXTS = ["Simple", "Rare", "Epic", "Legendary", "Boss"]
const BASE_COST = 125

@onready var selector = $SelectorFrame
var rolling = false

var current_rare = 0
var shake_tween
var original_position

# ---------------- READY ----------------

func _ready():
	update_ui()
	create_boost_buttons(true)

# ---------------- UI ----------------

func update_ui():
	coins_label.text = "Монеты: %d" % GameData.player_coins
	rare_label.text = RARE_TEXTS[current_rare]

	var show_random = not boost_size() and current_rare < 4
	rand_buy_button.visible = show_random

	if show_random:
		var cost = BASE_COST * max(current_rare + 1, 1)
		rand_buy_button.text = "Random Buy: %d" % cost


# ---------------- GRID ----------------

func create_boost_buttons(effect):
	for c in grid.get_children():
		c.queue_free()

	var delay_step := 0.05
	var i := 0

	for id in GameData.available_boosts:
		var d = GameData.available_boosts[id]
		if d.get("rare", -1) != current_rare:
			continue

		var btn = BOOST_BUTTON_SCENE.instantiate()
		btn.boost_id = id
		btn.setup_boost(d, d.unlocked)
		grid.add_child(btn)

		btn.pressed.connect(_on_boost_button_pressed.bind(id))

		btn.modulate.a = 0.0
		btn.scale = Vector2(0.8, 0.8)
		
		if effect:
			var tw = create_tween()
			tw.tween_interval(i * delay_step)
			tw.tween_property(btn, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(btn, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		else:
			btn.modulate.a = 1.0
			btn.scale = Vector2.ONE
			
		btn.call_deferred("_center_pivot")
		i += 1

# ---------------- BUTTON EVENTS ----------------
func _on_boost_button_pressed(boost_id: String):
	var boost_data = GameData.available_boosts[boost_id]

	if boost_data.unlocked or boost_data.type == "boss":
		Input.vibrate_handheld(50)
		return
	
	if GameData.player_coins < boost_data.price:
		Input.vibrate_handheld(50)
		return

	GameData.player_coins -= boost_data.price
	boost_data.unlocked = true
	GameData.save_game()

	update_ui()
	create_boost_buttons(false)
	Input.vibrate_handheld(20)

func _on_left_pressed():
	if current_rare > 0:
		current_rare -= 1
		update_ui()
		create_boost_buttons(true)

func _on_right_pressed():
	if current_rare < RARE_TEXTS.size() - 1:
		current_rare += 1
		update_ui()
		create_boost_buttons(true)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scene/game/shop_lobby/shop_lobby.tscn")

func _on_random_buy_pressed():
	if rolling:
		return

	rand_buy_button.disabled = true
	
	var total_price = BASE_COST * max(current_rare + 1, 1)
	var available = []

	for boost_id in GameData.available_boosts:
		var b = GameData.available_boosts[boost_id]
		if b.rare == current_rare and not b.unlocked and b.get("type") != "boss":
			available.append(boost_id)

	if available.is_empty():
		Input.vibrate_handheld(50)
		return
		
	if GameData.player_coins < total_price:
		Input.vibrate_handheld(50)
		return

	var random_id = available.pick_random()
	# получаем кнопки и final_button
	var buttons = get_buttons_of_current_rare()
	var final_button = get_button_by_id(random_id)

	# анимация
	await play_random_selection_animation(buttons, final_button)

	# покупка (кнопки ещё не пересозданы)
	GameData.player_coins -= total_price
	GameData.available_boosts[random_id].unlocked = true
	GameData.save_game()

	# теперь можно обновлять UI
	update_ui()
	create_boost_buttons(false)


	Input.vibrate_handheld(20)  # лёгкая вибрация успеха

# ---------------- EFFECTS ----------------

func phone_vibrate(intensity := 50):
	if Engine.has_singleton("HapticFeedback"):
		var h = Engine.get_singleton("HapticFeedback")
		h.vibrate(intensity)

func show_random_purchase_effect(boost_name: String):
	var popup := Label.new()
	popup.text = "Случайная покупка!\n" + boost_name
	popup.add_theme_font_size_override("font_size", 24)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.modulate = Color.GOLD
	popup.position = size / 2 - Vector2(100, 50)
	add_child(popup)

	var tween = create_tween()
	tween.tween_property(popup, "modulate", Color(1, 1, 1, 0), 2.0)
	tween.parallel().tween_property(popup, "position", popup.position + Vector2(0, -50), 2.0)
	tween.tween_callback(popup.queue_free)

func play_random_selection_animation(buttons: Array, final_button: Button):
	if rolling:
		return
	rolling = true
	
	rand_buy_button.disabled = true
	disable_all_boost_buttons()

	selector.visible = true
	selector.modulate.a = 1.0

	# если кнопок нет — аварийный выход
	if buttons.is_empty():
		selector.visible = false
		rolling = false
		rand_buy_button.disabled = false
		return

	var index := 0
	var total := 30
	var slowdown := 0.02

	# Основная рулетка
	for step in range(total):
		var btn = buttons[index % buttons.size()]
		selector.global_position = btn.global_position
		selector.size = btn.size

		await get_tree().create_timer(0.03 + step * slowdown).timeout
		index += 1

	# Движение к финальному бусту
	for i in range(5):
		selector.global_position = final_button.global_position
		selector.size = final_button.size
		await get_tree().create_timer(0.08).timeout

	# Исчезание рамки
	var t = create_tween()
	t.tween_property(selector, "modulate:a", 0.0, 0.3)
	await t.finished

	selector.visible = false
	rolling = false
	enable_all_boost_buttons()
	rand_buy_button.disabled = false

# ---------------- UTILS ----------------

func boost_size() -> bool:
	var unlocked := 0
	var total := 0
	for boost_data in GameData.available_boosts.values():
		if boost_data["rare"] == current_rare:
			total += 1
			if boost_data.unlocked:
				unlocked += 1
	return unlocked >= total - 1

func get_buttons_of_current_rare() -> Array:
	var arr := []
	for btn in grid.get_children():
		var data = GameData.available_boosts[btn.boost_id]
		if not data.unlocked:
			arr.append(btn)
	return arr

func get_button_by_id(id: String) -> Button:
	for btn in grid.get_children():
		if btn.boost_id == id:
			return btn
	return null

func disable_all_boost_buttons():
	for btn in grid.get_children():
		btn.disabled = true

func enable_all_boost_buttons():
	for btn in grid.get_children():
		btn.disabled = false
