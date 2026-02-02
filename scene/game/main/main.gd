extends Node

@export var all_enemy_scenes: Array[PackedScene] = []
@export var default_bosses: Array[PackedScene] = []
@export var freeze_bosses: Array[PackedScene] = []
@export var lava_bosses: Array[PackedScene] = []
@export var base_scenes_dict = {
	25: preload("res://scene/enemies/enemy_bases/base1/base_1.tscn"),
	50: preload("res://scene/enemies/enemy_bases/base2/base_2.tscn"),
	75: preload("res://scene/enemies/enemy_bases/base3/base_3.tscn")
}

var current_stage: int = 1
var enemies_in_stage: int = 0
var max_enemies_per_stage: int = 6
var boss_spawned: bool = false
var is_waiting_for_clear: bool = false
var isBoss = false
var isDeath = false

var used_default_bosses: Array[int] = []
var used_freeze_bosses: Array[int] = []
var used_lava_bosses: Array[int] = []

var enemy_tiers = {
	"default_easy": [0, 1],
	"default_medium": [1, 2, 3],
	"default_hard": [2, 3, 4, 5],
	"default_elite1": [3, 4, 5, 6, 7],
	"default_elite2": [5, 6, 7, 8, 9],
	"freeze_easy": [10, 11],
	"freeze_medium": [10, 11, 12],
	"freeze_hard": [12, 13, 14, 15],
	"freeze_elite1": [14, 15, 16, 17, 18],
	"freeze_elite2": [15, 16, 17, 18],
	"lava_easy": [19, 20],
	"lava_medium": [19, 20, 21],
	"lava_hard": [21, 22, 23, 24],
	"lava_elite1": [22, 23, 24, 25],
	"lava_elite2": [25, 26, 27],
	"all": [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27]
}

func _ready():
	Background.set_speed(150, 0.6)
	randomize()
	var viewport = get_viewport()
	var scale = max(1, floor(viewport.size.y / 1280))
	viewport.scaling_3d_scale = scale
	new_game()
	start_stage()

func _on_use_rashodnik(id):
	if id == "hot_oil":
		$Player.apply_hot_oil()
		$Vignette.normal_hp()
	elif id == "fire_extinguisher":
		$Player.apply_fire_extinguisher()
	elif id == "battery":
		$Player.apply_battery()
	elif id == "health_kit":
		$Player.apply_health_kit()
	elif id == "smoke_grenade":
		$Player.apply_smoke_grenade()
	elif id == "grenade":
		$Player.apply_grenade()
	elif id == "grenade_green":
		$Player.apply_grenade_green()
	elif id == "grenade_contact":
		$Player.apply_grenade_contact()

# --- Логика стадий --- #

func start_stage():
	$ClearCheckTimer.start(1)
	isBoss = false
	boss_spawned = false
	is_waiting_for_clear = false
	enemies_in_stage = 0
	$HUD.update_stage(current_stage)
	
	@warning_ignore("integer_division")
	max_enemies_per_stage = clamp(6 + (current_stage / 10), 6, 10)
	
	if current_stage % 5 == 0:
		max_enemies_per_stage = 1
		$MobTimer.wait_time = 3.0
	else:
		$MobTimer.wait_time = max(0.3, 1.0 - (current_stage * 0.01))

func next_stage():
	current_stage += 1
	if current_stage == 51:
		$MobTimer.stop()
		$BoostTimer.stop()
		await get_tree().create_timer(3).timeout
		get_tree().call_group("boosts", "full_speed_up")
		get_tree().call_group("bullets", "queue_free")
		get_tree().call_group("coins", "full_speed_up")
		Background.set_speed(1000, 0.6)
		await get_tree().create_timer(5).timeout
		Background.set_lava_background()
		await get_tree().create_timer(5).timeout
		start_stage()
		$MobTimer.start()
		$BoostTimer.start()
		Background.set_speed(150, 0.6)
	elif current_stage == 26:
		$MobTimer.stop()
		$BoostTimer.stop()
		await get_tree().create_timer(3).timeout
		get_tree().call_group("boosts", "full_speed_up")
		get_tree().call_group("bullets", "queue_free")
		get_tree().call_group("coins", "full_speed_up")
		Background.set_speed(1000, 0.6)
		await get_tree().create_timer(5).timeout
		Background.set_freeze_background()
		await get_tree().create_timer(5).timeout
		start_stage()
		$MobTimer.start()
		$BoostTimer.start()
		Background.set_speed(150, 0.6)
	else:
		$MobTimer.stop()
		$BoostTimer.stop()
		await get_tree().create_timer(1.5).timeout
		get_tree().call_group("boosts", "speed_up")
		get_tree().call_group("bullets", "queue_free")
		get_tree().call_group("coins", "speed_up")
		Background.set_speed(400, 0.6)
		await get_tree().create_timer(2).timeout
		start_stage()
		$MobTimer.start()
		$BoostTimer.start()
		Background.set_speed(150, 0.6)

# --- Основной цикл --- #
func _on_clear_check_timer_timeout():
	if is_waiting_for_clear and not are_enemies_present():
		if isBoss:
			$BoostTimer.start()
		complete_stage()

func _on_mob_timer_timeout():
	if enemies_in_stage >= max_enemies_per_stage:
		is_waiting_for_clear = true
		return
	
	if current_stage == 25 and not boss_spawned:
		spawn_base(current_stage)
		boss_spawned = true
	elif current_stage == 50 and not boss_spawned:
		spawn_base(current_stage)
		boss_spawned = true
	elif current_stage == 75 and not boss_spawned:
		spawn_base(current_stage)
		boss_spawned = true
	elif current_stage % 5 == 0 and not boss_spawned:
		spawn_boss()
		boss_spawned = true
	else:
		spawn_normal_enemy()
	
	enemies_in_stage += 1
	
	if enemies_in_stage >= max_enemies_per_stage:
		is_waiting_for_clear = true

func complete_stage():
	is_waiting_for_clear = false
	if not isDeath:
		next_stage()

func are_enemies_present() -> bool:
	var all_enemies = get_tree().get_nodes_in_group("enemies").size()
	var friendly = get_tree().get_nodes_in_group("friendly_enemies").size()
	return max(0, all_enemies - friendly) > 0

# --- Спавн логика --- #

func spawn_normal_enemy():
	var available_enemies = get_available_enemies()
	if available_enemies.is_empty():
		return
	
	var enemy_scene = available_enemies.pick_random()
	var enemy = enemy_scene.instantiate()
	enemy.add_to_group("enemies")

	var spawn_location = $MobPath/MobSpawnLocation
	spawn_location.progress_ratio = randf()
	enemy.position = spawn_location.position
	add_child(enemy)

func spawn_boss():
	isBoss = true
	$BoostTimer.stop()
	
	var boss_index = get_random_boss_for_stage()
	var boss_scene = get_boss_scene_for_stage(boss_index)
	
	if boss_scene:
		var boss = boss_scene.instantiate()
		boss.add_to_group("enemies")
		
		boss.global_position = $MobPath/MobSpawnLocation.global_position
		
		add_child(boss)
		print("Спавним босса ", boss_index + 1, " на этапе ", current_stage)

func get_random_boss_for_stage() -> int:
	if current_stage <= 25:
		return get_random_unused_boss(default_bosses, used_default_bosses)
	elif current_stage <= 50:
		return get_random_unused_boss(freeze_bosses, used_freeze_bosses)
	else:
		return get_random_unused_boss(lava_bosses, used_lava_bosses)

func get_random_unused_boss(boss_array: Array[PackedScene], used_array: Array[int]) -> int:
	if boss_array.is_empty():
		return -1
	
	# СОЗДАЕМ СПИСОК ДОСТУПНЫХ БОССОВ
	var available_bosses = []
	for i in range(boss_array.size()):
		if not used_array.has(i):
			available_bosses.append(i)
	
	# ЕСЛИ ВСЕ БОССЫ ИСПОЛЬЗОВАНЫ - СБРАСЫВАЕМ ДЛЯ НОВОЙ ИГРЫ
	if available_bosses.is_empty():
		used_array.clear()
		available_bosses = range(boss_array.size())
	
	# ВЫБИРАЕМ СЛУЧАЙНОГО БОССА
	var random_boss = available_bosses.pick_random()
	used_array.append(random_boss)
	
	return random_boss

func get_boss_scene_for_stage(boss_index: int) -> PackedScene:
	if current_stage <= 25:
		if boss_index >= 0 and boss_index < default_bosses.size():
			return default_bosses[boss_index]
	elif current_stage <= 50:
		if boss_index >= 0 and boss_index < freeze_bosses.size():
			return freeze_bosses[boss_index]
	else:
		if boss_index >= 0 and boss_index < lava_bosses.size():
			return lava_bosses[boss_index]
	
	return null

func spawn_base(stage_number: int):
	isBoss = true
	$BoostTimer.stop()
	
	if not base_scenes_dict.has(stage_number):
		return
	
	var base_scene = base_scenes_dict[stage_number]
	var base = base_scene.instantiate()
	base.add_to_group("enemies")
	base.position = $MobPath/MobSpawnLocation.position
	add_child(base)
# --- Вспомогательные функции --- #

func get_current_enemy_tier() -> String:
	@warning_ignore("integer_division")
	var stage_group = (current_stage - 1) / 5
	var stage_in_group = (current_stage - 1) % 5
	if stage_in_group == 4:
		stage_group = max(0, stage_group - 1)
	
	match stage_group:
		0: return "default_easy"
		1: return "default_medium"
		2: return "default_hard"
		3: return "default_elite1"
		4: return "default_elite2"
		5: return "freeze_easy"
		6: return "freeze_medium"
		7: return "freeze_hard"
		8: return "freeze_elite1"
		9: return "freeze_elite2"
		10: return "lava_easy"
		11: return "lava_medium"
		12: return "lava_hard"
		13: return "lava_elite1"
		14: return "lava_elite2"
		_: return "all"

func get_available_enemies() -> Array[PackedScene]:
	var tier = get_current_enemy_tier()
	var available: Array[PackedScene] = []
	if enemy_tiers.has(tier):
		for enemy_index in enemy_tiers[tier]:
			if enemy_index < all_enemy_scenes.size():
				available.append(all_enemy_scenes[enemy_index])
	return available

# --- Игровой цикл --- #

func new_game():
	isDeath = false
	current_stage = GameData.start_stg

	used_default_bosses.clear()
	used_freeze_bosses.clear()
	used_lava_bosses.clear()
	
	$Vignette.normal_hp()
	if current_stage < 26:
		Background.set_normal_background()
	elif current_stage < 51:
		Background.set_freeze_background()
	else:
		Background.set_lava_background()
	$HUD.update_stage(current_stage)
	#get_tree().call_group("boosts", "queue_free")
	get_tree().call_group("bullets", "queue_free")
	get_tree().call_group("coins", "queue_free")
	$Player.restart()
	$Player.start($StartPosition.position)
	$StartTimer.start()


func _on_start_timer_timeout():
	$MobTimer.start()

func _on_boost_timer_timeout():
	spawn_random_boost()

func spawn_random_boost():
	var boost_scene_map = {
		"res_health": preload("res://scene/boosts/res_health/res_health.tscn"),
		"regen_hp": preload("res://scene/boosts/regen_hp/regen_hp.tscn"),
		"boost_bullet": preload("res://scene/boosts/boost_bullet/boost_bullet.tscn"),
		"double_bullet_h": preload("res://scene/boosts/double_bullet_h/double_bullet_h.tscn"),
		"double_bullet_v": preload("res://scene/boosts/double_bullet_v/double_bullet_v.tscn"),
		"triple_bullet_h": preload("res://scene/boosts/triple_bullet_h/triple_bullet_h.tscn"),
		"spawn_meteors": preload("res://scene/boosts/spawn_meteors/spawn_meteors.tscn"),
		"laser_bullet": preload("res://scene/boosts/laser_bullet/laser_bullet.tscn"),
		"wall_sheald": preload("res://scene/boosts/wall_sheald/wall_sheald.tscn"),
		"boost_magma_bullet": preload("res://scene/boosts/boost_magma_bullet/boost_magma_bullet.tscn"),
		"triple_bullet_rotate": preload("res://scene/boosts/triple_bullet_rotate/triple_bullet_rotate.tscn"),
		"spawn_feathers": preload("res://scene/boosts/spawn_feather/spawn_feather.tscn"),
		"spawn_dragon_sheald": preload("res://scene/boosts/dragon_sheald/boost_dragon_sheald.tscn"),
		"spawn_companion" : preload("res://scene/boosts/spawn_companion/spawn_companion.tscn"),
		"spawn_egg": preload("res://scene/boosts/spawn_egg/spawn_egg.tscn"),
		"spawn_lava_balls": preload("res://scene/boosts/spawn_lava_balls/spawn_lava_balls.tscn"),
		"spear_bullet": preload("res://scene/boosts/spear_bullet/spear_bullet_boost.tscn"),
		"spawn_lava_lasers": preload("res://scene/boosts/spawn_lasers/spawn_lasers.tscn"),
	}
	
	var unlocked_boosts = []
	for boost_id in GameData.available_boosts:
		var data = GameData.available_boosts[boost_id]
		if data.unlocked and boost_id in boost_scene_map:
			unlocked_boosts.append(boost_id)
	
	if unlocked_boosts.is_empty():
		return
	
	var random_boost_id = unlocked_boosts.pick_random()
	var boost_scene = boost_scene_map[random_boost_id]
	var boost = boost_scene.instantiate()
	
	var spawn_location = $MobPath/MobSpawnLocation
	spawn_location.progress_ratio = randf()
	boost.position = spawn_location.position
	add_child(boost)

func _on_player_update_hp(hp):
	$Vignette.check_hp(hp)
	if hp <= 0:
		game_over()
	if $HUD:
		$HUD.update_hp(hp)

func game_over():
	isDeath = true
	get_tree().call_group("enemies", "queue_free")
	$MobTimer.stop()
	$BoostTimer.stop()
	$HUD.show_game_over()
	GameData.record_stage = max(current_stage, GameData.record_stage)
	GameData.save_game()

func _on_hud_restart():
	GameData.load_game()
	new_game()
	start_stage()

func _on_player_take_damage(hp, frz_stage):
	$Vignette.hit_animation(hp, frz_stage)
