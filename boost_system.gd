extends Node
class_name BoostSystem

# Ссылки на компоненты игрока
var player: Node
var cd_shot_timer: Timer

# Настройки бустов
var boost_time: float

# Активные таймеры бустов
var active_boost_timers = {}

func initialize(player_node: Node, shot_timer_node: Timer, base_boost_time: float):
	player = player_node
	cd_shot_timer = shot_timer_node
	boost_time = base_boost_time

# ОСНОВНАЯ ФУНКЦИЯ ДЛЯ ПРИМЕНЕНИЯ БУСТОВ
func apply_boost(boost_type: String, duration: float = 0.0):
	if duration == 0.0:
		duration = boost_time
	
	# Если буст уже активен - перезапускаем таймер
	if active_boost_timers.has(boost_type):
		var timer = active_boost_timers[boost_type]
		if is_instance_valid(timer) and timer.is_inside_tree():
			timer.start(duration)
			print("Буст перезапущен: ", boost_type)
		else:
			# Если таймер невалиден, создаем новый
			active_boost_timers.erase(boost_type)
			_create_boost_timer(boost_type, duration)
	else:
		_create_boost_timer(boost_type, duration)

# ФУНКЦИЯ ДЛЯ СОЗДАНИЯ ТАЙМЕРА БУСТА
func _create_boost_timer(boost_type: String, duration: float):
	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(_on_boost_timeout.bind(boost_type))
	add_child(timer)
	active_boost_timers[boost_type] = timer
	
	# Используем call_deferred чтобы убедиться что таймер в дереве
	call_deferred("_start_timer_deferred", timer, duration, boost_type)

func _start_timer_deferred(timer: Timer, duration: float, boost_type: String):
	if is_instance_valid(timer) and timer.is_inside_tree():
		timer.start(duration)
		print("Буст активирован: ", boost_type)
		
		# Применяем эффект буста после того как таймер запущен
		_apply_boost_effect(boost_type)
	else:
		push_error("Таймер не в дереве сцены: " + boost_type)

# ФУНКЦИЯ ДЛЯ ПРИМЕНЕНИЯ ЭФФЕКТОВ БУСТА
func _apply_boost_effect(boost_type: String):
	match boost_type:
		"strong_bullet":
			player.bullet_scene = load("res://scene/player_scenes/strong_bullet/strong_bullet.tscn")
		"double_bullet_v":
			player.quantity_bullet_v = 2
		"double_bullet_h":
			player.quantity_bullet_h = 2
		"triple_bullet_h":
			player.quantity_bullet_h = 3
		"laser_bullet":
			player.laser_bullet = true
			player.start_laser()
		"magma_bullet":
			player.bullet_scene = load("res://scene/player_scenes/player_magma_bullet/player_magma_bullet.tscn")
			cd_shot_timer.start(0.6)
		"spear_bullet":
			player.bullet_scene = load("res://scene/player_scenes/spear_player/spear_player.tscn")
			player.quantity_bullet_h = 2
			cd_shot_timer.start(0.6)
		"wall_shield":
			player.call_deferred("_deferred_spawn_shield")
		"dragon_sheald":
			player.call_deferred("_deferred_spawn_dragon_shield")
		"spawn_feathers":
			player.isFeatherBoost = true

func _on_boost_timeout(boost_type: String):
	print("Буст заканчивается: ", boost_type)
	
	# Отключаем эффект буста
	_disable_boost_effect(boost_type)
	
	# Удаляем таймер
	if active_boost_timers.has(boost_type):
		var timer = active_boost_timers[boost_type]
		if is_instance_valid(timer):
			timer.queue_free()
		active_boost_timers.erase(boost_type)

# ФУНКЦИЯ ДЛЯ ОТКЛЮЧЕНИЯ ЭФФЕКТОВ БУСТА
func _disable_boost_effect(boost_type: String):
	match boost_type:
		"strong_bullet":
			player.make_default_bullet()
		"double_bullet_v":
			player.quantity_bullet_v = 1
		"double_bullet_h":
			player.quantity_bullet_h = 1
			player.rotate_bullet = false
		"triple_bullet_h":
			player.quantity_bullet_h = 1
			player.rotate_bullet = false
		"laser_bullet":
			player.laser_bullet = false
			player.stop_laser()
		"magma_bullet":
			player.make_default_bullet()
			if is_instance_valid(cd_shot_timer):
				cd_shot_timer.start(player.cd_shot_time)
		"spear_bullet":
			player.make_default_bullet()
			player.quantity_bullet_h = 1
			if is_instance_valid(cd_shot_timer):
				cd_shot_timer.start(player.cd_shot_time)
		"wall_shield":
			if player.current_shield and is_instance_valid(player.current_shield):
				player.current_shield.queue_free()
				player.current_shield = null
		"dragon_sheald":
			if player.current_shield and is_instance_valid(player.current_shield):
				player.current_shield.queue_free()
				player.current_shield = null
		"spawn_feathers":
			player.isFeatherBoost = false

# ФУНКЦИЯ ДЛЯ ОЧИСТКИ ВСЕХ БУСТОВ
func clear_all_boosts():
	# Останавливаем все таймеры
	for boost_type in active_boost_timers:
		var timer = active_boost_timers[boost_type]
		if is_instance_valid(timer):
			timer.stop()
			timer.queue_free()
	
	active_boost_timers.clear()
	
	# Сбрасываем все флаги бустов у игрока
	player.strong_bullet = false
	player.laser_bullet = false
	player.magma_bullet = false
	player.quantity_bullet_v = 1
	player.quantity_bullet_h = 1
	player.rotate_bullet = false
	player.isFeatherBoost = false
	
	# Останавливаем лазер
	player.stop_laser()
	
	# Удаляем щит
	if player.current_shield and is_instance_valid(player.current_shield):
		player.current_shield.queue_free()
		player.current_shield = null
	
	print("Все бусты очищены")

# Проверка активен ли буст
func is_boost_active(boost_type: String) -> bool:
	return active_boost_timers.has(boost_type)

# Получить оставшееся время буста
func get_boost_remaining_time(boost_type: String) -> float:
	if active_boost_timers.has(boost_type):
		var timer = active_boost_timers[boost_type]
		if is_instance_valid(timer) and timer.is_inside_tree():
			return timer.time_left
	return 0.0
