extends CanvasLayer

signal restart
signal use_rashodnik(id)

@onready var menu_btn      = $MarginContainer/VBoxContainer/VBoxContainer/Menu
@onready var restart_btn   = $MarginContainer/VBoxContainer/VBoxContainer/Restart
@onready var hp_bar        = $MarginContainer/VBoxContainer/HBoxContainer/HPBar
@onready var stage_label   = $MarginContainer/VBoxContainer/HBoxContainer2/Stage
@onready var pause_btn     = $MarginContainer/VBoxContainer/HBoxContainer2/Stage/Pause
@onready var coins_label   = $MarginContainer/VBoxContainer/HBoxContainer2/Stage/CoinsLabel
@onready var rashodnik_cd  = $RashodnikCD

var can_use_rashodnik: bool = true
var current_collect_value := 0
var current_effect_label: Label
var collect_timer: Timer


func _ready():
	var safe_area = DisplayServer.get_display_safe_area()
	$MarginContainer.add_theme_constant_override("margin_top", safe_area.position.y)

	menu_btn.hide()
	restart_btn.hide()

	hp_bar.max_value = GameData.max_hp
	hp_bar.value = GameData.max_hp
	coins_label.text = "Coins: " + str(GameData.player_coins)

	collect_timer = Timer.new()
	collect_timer.wait_time = 1.0
	collect_timer.one_shot = true
	collect_timer.timeout.connect(_on_collect_timeout)
	add_child(collect_timer)

	update_rashodniki_bar()
	
func update_hp(hp):
	hp_bar.value = hp
	
func update_stage(stage):
	if stage % 25 == 0:
		stage_label.text = "Base"
	elif stage % 5 == 0:
		stage_label.text = "Boss" 
	else: 
		stage_label.text = "Stage " + str(stage)
		
func _on_menu_pressed():
	menu_btn.hide()
	restart_btn.hide()
	Background.set_normal_background()
	get_tree().change_scene_to_file("res://scene/game/main_menu/main_menu.tscn")

func _on_restart_pressed():
	restart.emit()
	reload()

func reload():
	can_use_rashodnik = true
	menu_btn.hide()
	restart_btn.hide()
	pause_btn.show() 
	update_hp(GameData.max_hp) 
	current_collect_value = 0
	if current_effect_label and is_instance_valid(current_effect_label):
		current_effect_label.queue_free()
		current_effect_label = null
		update_rashodniki_bar()

func show_game_over():
	menu_btn.show()
	restart_btn.show()
	pause_btn.hide()
	can_use_rashodnik = false
	update_rashodniki_bar()
	
func _on_player_update_coins_label(value):
	GameData.player_coins += value
	coins_label.text = "Coins: " + str(GameData.player_coins)
	current_collect_value += value
	collect_timer.start()
	update_ui_collect_effect(current_collect_value)
	
func update_ui_collect_effect(total_value: int):
	# Удаляем старый label если он есть
	if current_effect_label and is_instance_valid(current_effect_label):
		current_effect_label.queue_free()
	
	# Создаем новый label
	current_effect_label = Label.new()
	current_effect_label.text = "+" + str(total_value)
	current_effect_label.add_theme_color_override("font_color", Color.GOLD)
	current_effect_label.add_theme_font_size_override("font_size", 28)
	current_effect_label.add_theme_color_override("font_outline_color", Color.BLACK)
	current_effect_label.add_theme_constant_override("outline_size", 8)
	
	# ВАЖНО: Добавляем в сцену ПЕРЕД анимацией
	add_child(current_effect_label)
	
	# Даем время на добавление в дерево
	await get_tree().process_frame
	
	# Позиция рядом с coins_label
	var effect_position = Vector2(
		coins_label.position.x + coins_label.size.x + 20, 
		coins_label.position.y
	)
	current_effect_label.position = effect_position
	
	# Анимация
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		current_effect_label, "position", 
		effect_position + Vector2(0, -60), 1.2
	)
	tween.tween_property(
		current_effect_label, "scale", 
		Vector2(1.2, 1.2), 0.3
	).from(Vector2(0.5, 0.5))
	tween.tween_property(
		current_effect_label, "modulate", 
		Color(1, 1, 1, 0), 1.2
	).set_delay(0.2)
	
	# Удаление через таймер
	get_tree().create_timer(1.2).timeout.connect(func():
		if is_instance_valid(current_effect_label):
			current_effect_label.queue_free()
			current_effect_label = null
	)
				
func _on_collect_timeout():
	current_collect_value = 0
	if current_effect_label and is_instance_valid(current_effect_label):
		current_effect_label.queue_free()
		current_effect_label = null

# ----------- ОБНОВЛЕНИЕ РАСХОДНИКОВ -------------

func update_rashodniki_bar():
	var bar = $MarginContainer/VBoxContainer/HBoxContainer/RBar
	
	for child in bar.get_children():
		child.queue_free()
	
	for id in GameData.get_equipped_rashodniki():
		var data = GameData.rashodniki[id]
		var btn = create_rashodnik_button(id, data)
		bar.add_child(btn)

func _on_rashodnik_pressed(id: String):
	if not can_use_rashodnik:
		return
	print("Использован расходник: ", id)

	if GameData.rashodniki[id].quantity > 0:
		GameData.rashodniki[id].quantity -= 1
		GameData.save_game()
		emit_signal("use_rashodnik", id)
		can_use_rashodnik = false
		$RashodnikCD.start()
		update_rashodniki_bar()
	else:
		print("Расходник закончился!")

func create_rashodnik_button(id: String, data: Dictionary) -> Button:
	var btn = Button.new()
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	var quantity = data.quantity
	if quantity <= 0:
		btn.modulate = Color(0.4, 0.4, 0.4, 1)
		btn.text = "0"
	elif can_use_rashodnik == false:
		btn.modulate = Color(0.4, 0.4, 0.4, 1)
		btn.text = "Block"
	else:
		btn.text = str(quantity)
	btn.custom_minimum_size = Vector2(100, 120)
	btn.icon = load(data.icon)
	btn.expand_icon = true

	btn.pressed.connect(func():
		_on_rashodnik_pressed(id)
	)

	return btn

func _on_rashodnik_cd_timeout():
	can_use_rashodnik = true
	update_rashodniki_bar()
