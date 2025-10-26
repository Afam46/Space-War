extends Node

@export var all_enemy_scenes: Array[PackedScene] = []  # ВСЕ враги от слабых к сильным
@export var boss_enemies: Array[PackedScene] = []
@export var all_boost_scenes: Array[PackedScene] = []        # Боссы для каждого 5-го уровня
var score
var current_stage: int = 1
var enemies_in_stage: int = 0
var max_enemies_per_stage: int = 8
var boss_spawned: bool = false
var is_waiting_for_clear: bool = false

# Группы врагов по силе (индексы из all_enemy_scenes)
var enemy_tiers = {
	"weak": [0, 1],       # Слабые враги (уровни 1-4, 6-9 и т.д.)
	"medium": [0, 1, 2, 3],     # Средние враги (уровни 11-14, 16-19 и т.д.)  
	"strong": [0, 1, 2, 3, 4, 5],     # Сильные враги (уровни 21-24, 26-29 и т.д.)
	"elite": [0, 1, 2, 3, 4, 5, 6, 7]       # Элитные враги (уровни 31+)
}

func _ready():
	new_game()
	start_stage()
	
func _on_mob_timer_timeout():
	if enemies_in_stage >= max_enemies_per_stage:
		is_waiting_for_clear = true
		return
	
	if current_stage % 5 == 0 and not boss_spawned:
		spawn_boss()
		boss_spawned = true
		enemies_in_stage += 1
	else:
		spawn_normal_enemy()
		enemies_in_stage += 1
	
	# После спавна всех врагов уровня - ждем очистки
	if enemies_in_stage >= max_enemies_per_stage:
		is_waiting_for_clear = true

func _process(_delta):
	if is_waiting_for_clear and not are_enemies_present():
		complete_stage()

func complete_stage():
	is_waiting_for_clear = false
	next_stage()

func are_enemies_present() -> bool:
	return get_tree().get_nodes_in_group("enemies").size() > 0
	
func game_over():
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	current_stage = 1
	$HUD.update_hp(3)
	$HUD.update_stage(current_stage)
	$Player.restart()
	$Player.start($StartPosition.position)
	$StartTimer.start()
	


func _on_start_timer_timeout():
	$MobTimer.start()

func _on_player_hit(hp):
	if hp <= 0:
		game_over()
	if $HUD:
		$HUD.update_hp(hp)

func _on_hud_start_game():
	new_game()


func get_current_enemy_tier() -> String:
	# Определяем какой группе врагов соответствует текущий этап
	@warning_ignore("integer_division")
	var stage_group = (current_stage - 1) / 5  # Группа из 5 этапов: 0, 1, 2, 3...
	var stage_in_group = (current_stage - 1) % 5  # Позиция в группе: 0,1,2,3,4
	
	# Этапы с боссами (5, 10, 15...) пропускаем для расчета силы врагов
	if stage_in_group == 4:  # Это этап с боссом
		stage_group = max(0, stage_group - 1)
	
	# Прогрессия силы обычных врагов
	if stage_group == 0: return "weak"      # Уровни 1-4, 6-9
	elif stage_group == 1: return "medium"  # Уровни 11-14, 16-19  
	elif stage_group == 2: return "strong"  # Уровни 21-24, 26-29
	else: return "elite"                    # Уровни 31+

func get_available_enemies() -> Array[PackedScene]:
	var tier = get_current_enemy_tier()
	var available: Array[PackedScene] = []
	
	if enemy_tiers.has(tier):
		for enemy_index in enemy_tiers[tier]:
			if enemy_index < all_enemy_scenes.size():
				available.append(all_enemy_scenes[enemy_index])
	
	# Если нет врагов в текущем тире, берем из предыдущего
	if available.is_empty():
		if tier == "medium": return get_enemies_by_tier("weak")
		elif tier == "strong": return get_enemies_by_tier("medium") 
		elif tier == "elite": return get_enemies_by_tier("strong")
	
	return available

func get_enemies_by_tier(tier: String) -> Array[PackedScene]:
	var enemies: Array[PackedScene] = []
	if enemy_tiers.has(tier):
		for enemy_index in enemy_tiers[tier]:
			if enemy_index < all_enemy_scenes.size():
				enemies.append(all_enemy_scenes[enemy_index])
	return enemies

func start_stage():
	$HUD.update_stage(current_stage)
	enemies_in_stage = 0
	boss_spawned = false
	
	# Настраиваем количество врагов в зависимости от этапа
	@warning_ignore("integer_division")
	max_enemies_per_stage = 6 + (current_stage / 2)  # Постепенно увеличиваем
	
	# Настройки для этапов с боссами
	if current_stage % 5 == 0:
		max_enemies_per_stage = 1  # Только босс
		$MobTimer.wait_time = 3.0  # Задержка перед боссом
		print("⭐ БОСС УРОВЕНЬ ", current_stage)
	else:
		$MobTimer.wait_time = 1.0 - (current_stage * 0.02)  # Ускоряем спавн
		$MobTimer.wait_time = max(0.3, $MobTimer.wait_time)  # Но не меньше 0.3 сек
		
		var tier = get_current_enemy_tier()
		print("Уровень ", current_stage, " | Группа врагов: ", tier)

func spawn_boss():
	@warning_ignore("integer_division")
	var boss_index = (current_stage / 5) - 1
	if boss_index < boss_enemies.size():
		var boss_scene = boss_enemies[boss_index]
		var boss = boss_scene.instantiate()
		
		boss.add_to_group("enemies")
		
		# Специальная позиция для босса
		boss.position = $MobPath/MobSpawnLocation.position
		
		
		add_child(boss)
		show_boss_warning()
		
		# Спецэффекты
		#$BossAppearSound.play()
		spawn_boss_particles(boss.position)

func spawn_normal_enemy():
	var available_enemies = get_available_enemies()
	if available_enemies.is_empty():
		push_warning("No available enemies for current tier!")
		return
	
	var enemy_scene = available_enemies[randi() % available_enemies.size()]
	var enemy = enemy_scene.instantiate()
	
	enemy.add_to_group("enemies")
	
	# Обычный спавн
	var spawn_location = $MobPath/MobSpawnLocation
	spawn_location.progress_ratio = randf()
	enemy.position = spawn_location.position
	
	# Усиливаем врагов в зависимости от этапа
#	apply_stage_buffs(enemy)
	
	add_child(enemy)

#func apply_stage_buffs(enemy: Node):
	#var stage_multiplier = 1.0 + (current_stage * 0.05)  # +5% за этап
	
	#if enemy.has_method("set_health"):
	#	enemy.max_health *= stage_multiplier
	#	enemy.health = enemy.max_health
	
	#if enemy.has_method("set_damage"):
	#	enemy.damage *= stage_multiplier
	
	#if enemy.has_method("set_speed"):
	#	enemy.speed *= (1.0 + (current_stage * 0.01))  # +1% скорости за этап

func _on_boss_defeated():
	print("Босс уровня ", current_stage, " побежден!")
	#give_boss_reward()
	next_stage()

func next_stage():
	current_stage += 1
	start_stage()

func show_boss_warning():
	var label = Label.new()
	label.text = "БОСС! Уровень " + str(current_stage)
	label.add_theme_font_size_override("font_size", 48)
	add_child(label)
	
	label.position = Vector2(180, 200)  # По центру экрана
	
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_interval(1.5)
	tween.tween_property(label, "scale", Vector2(0.5, 0.5), 0.3)
	tween.tween_callback(label.queue_free)

func spawn_boss_particles(pos: Vector2):
	# Создаем частицы для появления босса
	var particles = CPUParticles2D.new()
	particles.position = pos
	particles.emitting = true
	particles.one_shot = true
	add_child(particles)
	
	await get_tree().create_timer(2.0).timeout
	particles.queue_free()

#func give_boss_reward():
	# Награда за босса
#	var coins = 100 + (current_stage * 20)
#	var score = 500 + (current_stage * 100)
	
#	print("Награда: ", coins, " монет, ", score, " очков")
	
	# Здесь можно обновить UI с наградами


func _on_boost_timer_timeout():
	if randf() * 100 <= 33 + current_stage:
		if all_boost_scenes.size() > 0:
			var boost_index = randi_range(0, all_boost_scenes.size() - 1)
			var boost_scene = all_boost_scenes[boost_index]
			var boost = boost_scene.instantiate()
			var spawn_location = $MobPath/MobSpawnLocation
			spawn_location.progress_ratio = randf()
			boost.position = spawn_location.position
			add_child(boost)
