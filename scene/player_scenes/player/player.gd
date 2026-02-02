extends Area2D
var current_laser = null

signal update_hp(hp)
signal update_coins_label(value)
signal take_damage(hp, frz_stage)

var boost_system: BoostSystem

@onready var shot_sounds = [
	preload("res://aasounds/shot/shot_1.wav"),
	preload("res://aasounds/shot/shot_2.wav"),
	preload("res://aasounds/shot/shot_3.wav"),
	preload("res://aasounds/shot/shot_4.wav"),
	preload("res://aasounds/shot/shot_5.wav")
]

@onready var shot_players = [
	$ShotSound0,
	$ShotSound1,
	$ShotSound2,
	$ShotSound3,
	$ShotSound4
]

@onready var hit_sounds = [
	preload("res://aasounds/metal_hit/metal_hit_1.wav"),
	preload("res://aasounds/metal_hit/metal_hit_2.wav"),
	preload("res://aasounds/metal_hit/metal_hit_3.wav"),
	preload("res://aasounds/metal_hit/metal_hit_4.wav")
]

var shot_index = 0

@export var laser_scene: PackedScene
@export var spark: PackedScene
@export var meteor_scene: PackedScene
@export var freeze_particle_scene: PackedScene
@export var feather_scene: PackedScene
@export var companion_scene: PackedScene
@export var damage_number_scene: PackedScene
@export var clin_particles_scene: PackedScene
@export var electro_ball_scene: PackedScene
@export var lava_ball_scene: PackedScene
@export var egg_scene: PackedScene
@export var lava_laser_scene: PackedScene

var green_particles = preload("res://scene/particles/green_boost/green_boost.tscn")
var wall_sheald = preload("res://scene/player_scenes/wall_sheald/wall_sheald.tscn")
var dragon_sheald = preload("res://scene/player_scenes/wall_sheald/dragon_sheald.tscn")

@onready var cd_shot_timer = $CDShotTimer

var skin = GameData.skins[GameData.current_skin]

var bullet_scene = load(skin.bullet_scene)

var can_shot = true
var cd_shot = true
var cd_shot_time = 0.3
var first_speed = skin.speed
var speed = first_speed
var follow_mouse = false
var screen_size
var max_hp = GameData.max_hp + skin.hp_bonus
var hp = max_hp

# Флаги бустов (теперь управляются через boost_system)
var strong_bullet = false
var laser_bullet = false
var magma_bullet = false
var rotate_bullet = false
var quantity_bullet_v = 1
var quantity_bullet_h = 1
var isFeatherBoost = false
var boost_time = GameData.boost_time

#freeze
var freeze_stage := 0
var max_freeze_stage = skin.max_freeze_stage
var original_speed := 1000
var original_anim_speed := 1.0
var freeze_timer: Timer
var full_freeze_timer: Timer
var isFreeze = false
var freeze_imunitet = false

# --- Heat (lava biome) ---
var heat_stage := 0
var max_heat_stage := 5
var heat_timer: Timer
var heat_duration := 3.0  # время до снижения уровня
var is_overheated := false
var shot_spread := 0.0
var isHeat = false
var isClin = false

var hot_oil_timer: Timer

var current_shield: Node2D = null

func _ready():
	use_skin()
	boost_system = BoostSystem.new()
	boost_system.initialize(self, cd_shot_timer, GameData.boost_time)
	add_child(boost_system)
	
	screen_size = get_viewport_rect().size
	cd_shot_timer.start(cd_shot_time)

	original_speed = first_speed
	original_anim_speed = $AnimatedSprite2D.speed_scale
	
	freeze_timer = Timer.new()
	freeze_timer.one_shot = false
	freeze_timer.timeout.connect(_on_freeze_timer_timeout)
	add_child(freeze_timer)
	
	full_freeze_timer = Timer.new()
	full_freeze_timer.one_shot = true
	full_freeze_timer.timeout.connect(_on_full_freeze_timeout)
	add_child(full_freeze_timer)
	
	heat_timer = Timer.new()
	heat_timer.one_shot = false
	heat_timer.timeout.connect(_on_heat_timer_timeout)
	add_child(heat_timer)
	
	hot_oil_timer = Timer.new()
	hot_oil_timer.one_shot = true
	hot_oil_timer.wait_time = 10.0
	hot_oil_timer.timeout.connect(_on_hot_oil_timeout)
	add_child(hot_oil_timer)

func use_skin():
	var skin_id = GameData.current_skin
	var data = GameData.skins[skin_id]

	$AnimatedSprite2D.animation = data.animation_name
	$AnimatedSprite2D.play()

func _unhandled_input(event):
	if get_tree().paused:
		return
	if freeze_stage >= max_freeze_stage:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		follow_mouse = event.pressed
		if event.pressed and laser_bullet:
			start_laser()
		else:
			stop_laser()

func start_laser():
	$LaserSound.play()
	if current_laser == null:
		call_deferred("_deferred_start_laser")

func _deferred_start_laser():
	if current_laser == null:
		current_laser = laser_scene.instantiate()
		current_laser.global_position = global_position + Vector2(0, -452)
		current_laser.rotation = 0
		add_child(current_laser)

func stop_laser():
	$LaserSound.stop()
	if current_laser != null and is_instance_valid(current_laser):
		current_laser.queue_free()
		current_laser = null

func _physics_process(delta):
	if freeze_stage >= max_freeze_stage:
		return
	handle_mouse_movement(delta)

func handle_mouse_movement(delta):
	if not follow_mouse:
		return	
	elif laser_bullet:
		update_laser_position()
	elif cd_shot:
		shot()
	
	move_to_mouse(delta)

func update_laser_position():
	if current_laser != null:
		current_laser.global_position = global_position + Vector2(0, -452)
		current_laser.rotation = 0

func move_to_mouse(delta):
	var mouse_pos = get_global_mouse_position()
	position = global_position.move_toward(mouse_pos, speed * delta)
	position = position.clamp(Vector2.ZERO, screen_size)

func _on_body_entered(body):
	hit(body)

func hit(body):
	if body:
		if body.is_in_group("lava_enemies"):
			apply_heat(1)
			body_hit(body)
			if body.has_method("instant_death"):
				body.instant_death()
			if body.has_method("laser"):
				$HitTimer.start()
				laser_hit()
			elif body.has_method("destroy"):
				body.destroy(10)
		elif body and is_instance_valid(body) and body.is_in_group("freezing_enemies"):
			var freeze_power = 1
			if "freeze_power" in body:
				freeze_power = body.freeze_power
			freeze(freeze_power)
			body_hit(body)
			if body.has_method("instant_death"):
				body.instant_death()
			elif body.has_method("destroy"):
				body.destroy(10)
		elif body.has_method("laser"):
			$HitTimer.start()
			laser_hit()
			if body.has_method("destroy"):
				body.destroy(10)
		elif body.has_method("instant_death"):
			body.instant_death()
			body_hit(body)
		elif body.has_method("destroy"):
			body.destroy(10)
			body_hit(body)
		if body.has_method("slow"):
			speed = 100
			body_hit(body)
			await get_tree().create_timer(1).timeout
			if body:
				body.queue_free()
			speed = first_speed
			
	if hp <= 0:
		die()

func body_hit(body):
	var dm = body.damage
	hp -= dm
	
	play_hit_sound()
	
	if isFeatherBoost:
		spawn_feathers(3)
	update_hp.emit(hp)
	show_particles()
	if not isFreeze and not isHeat:
		hit_anim(dm)
	else:
		show_damage_number(dm)

func play_hit_sound():
	var sfx = hit_sounds[randi() % hit_sounds.size()]
	$HitSound.stream = sfx
	$HitSound.pitch_scale = randf_range(0.95, 1.05)
	$HitSound.play()

func _on_hit_timer_timeout():
	laser_hit()
	
func laser_hit():
	var laser_damage = randi_range(10, 15)
	hp -= laser_damage
	update_hp.emit(hp)
	show_particles()
	hit_anim(laser_damage)
	
	if hp <= 0:
		die()
		
func _on_body_exited(body):
	if body.has_method("laser"):
		$HitTimer.stop()
	
func die():
	_unfreeze()
	boost_system.clear_all_boosts()
	if freeze_timer:
		freeze_timer.stop()
	if full_freeze_timer:
		full_freeze_timer.stop()
	
	$AnimatedSprite2D.animation = "death"
	
	if $AnimatedSprite2D.sprite_frames:
		$AnimatedSprite2D.sprite_frames.set_animation_loop("death", false)
		
	$AnimatedSprite2D.play()

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	$Death.play()
	
	cd_shot = false
	$CDShotTimer.stop()
	speed = 0
	stop_laser()
	
	await $AnimatedSprite2D.animation_finished
	hide()

func hit_anim(damage = 0):
	take_damage.emit(hp, 0)
	Input.vibrate_handheld(50)
	show_damage_number(damage)
	hit_red_anim()

func hit_red_anim():
	$AnimatedSprite2D.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	$AnimatedSprite2D.modulate = Color.WHITE

func show_damage_number(damage: int):
	if damage_number_scene:
		var damage_number = damage_number_scene.instantiate()
		
		# Позиция над игроком
		var spawn_position = global_position + Vector2(randf_range(-10, 10), -60)
		
		get_parent().add_child(damage_number)
		damage_number.setup(damage, spawn_position)

func show_particles():
	var particles = spark.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.emitting = true
	particles.one_shot = true
	await get_tree().create_timer(2).timeout
	particles.queue_free()

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func shot():
	if freeze_stage >= max_freeze_stage:
		return
	
	if isClin:
		if randi() % 100 < 50:
			show_clin_particles()
			cd_shot = false
			$CDShotTimer.stop()
			await get_tree().create_timer(0.5).timeout
			$CDShotTimer.start()
			cd_shot = true
	
	cd_shot = false
	
	play_random_shot_sound()

	for v in range(quantity_bullet_v):
		for h in range(quantity_bullet_h):
			var bullet = bullet_scene.instantiate()
			
			var bullet_position = get_bullet_position(h, quantity_bullet_h)
			bullet.global_position = global_position + bullet_position
				
			if rotate_bullet and quantity_bullet_h > 1:
				if h == 0:
					bullet.set_direction_from_player(-PI/10)
				elif h == quantity_bullet_h - 1:
					bullet.set_direction_from_player(PI/10)
				else:
					bullet.rotation = 0
			else:
				bullet.rotation = 0
				
			if shot_spread:
				bullet.set_direction_from_player(randf_range(-shot_spread, shot_spread))
				
			add_child(bullet)
		await get_tree().create_timer(0.1).timeout

func play_random_shot_sound():
	var sfx = shot_sounds[randi() % shot_sounds.size()]

	var player = shot_players[shot_index]
	player.stream = sfx
	player.pitch_scale = randf_range(0.95, 1.05)
	player.play()

	shot_index = (shot_index + 1) % shot_players.size()

func get_bullet_position(bullet_index, total_bullets):
	match total_bullets:
		1:
			return Vector2(0, -102)
		2:
			match bullet_index:
				0: return Vector2(-54, -30)
				1: return Vector2(54, -30)
		3:
			match bullet_index:
				0: return Vector2(-54, -30)
				1: return Vector2(0, -102)
				2: return Vector2(54, -30)
		_:
			var x_offset = 0
			if total_bullets > 1:
				var total_width = (total_bullets - 1) * 24
				x_offset = -total_width / 2.0 + (bullet_index * 24)
			return Vector2(x_offset, -102)

func restart():
	_unfreeze()
	boost_system.clear_all_boosts()
	if freeze_timer:
		freeze_timer.stop()
	if full_freeze_timer:
		full_freeze_timer.stop()
	
	show()
	speed = first_speed
	$CDShotTimer.start()
	hp = max_hp
	speed = first_speed
	use_skin()
	
func add_coins(value):
	GameData.player_coins += value
	update_coins_label.emit(value)

#---Boosts---

func res_health(health):
	hp = min(hp + health, max_hp)
	update_hp.emit(hp)
	
func make_strong_bullet():
	boost_system.apply_boost("strong_bullet")

func make_double_bullet_v():
	boost_system.apply_boost("double_bullet_v")

func double_bullet_h():
	boost_system.apply_boost("double_bullet_h")

func triple_bullet_h(isRot = false):
	boost_system.apply_boost("triple_bullet_h")
	rotate_bullet = isRot

func make_laser_bullet():
	boost_system.apply_boost("laser_bullet")

func make_magma_bullet():
	boost_system.apply_boost("magma_bullet")

func make_spear_bullet():
	boost_system.apply_boost("spear_bullet")

func make_default_bullet():
	bullet_scene = load(skin.bullet_scene)

func spawn_lasers():
	call_deferred("_deffered_spawn_lasers")

func _deffered_spawn_lasers():
	var lava_laser = lava_laser_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/6, screen_size.y)
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/2.2, screen_size.y)
	get_parent().add_child(lava_laser)
	
	await get_tree().create_timer(4).timeout
	
	lava_laser = lava_laser_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/6, screen_size.y)
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/1.8, screen_size.y)
	get_parent().add_child(lava_laser)
	
	await get_tree().create_timer(4).timeout
	
	lava_laser = lava_laser_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/2.5, screen_size.y)
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/1.5, screen_size.y)
	get_parent().add_child(lava_laser)

func spawn_egg():
	call_deferred("_deffered_spawn_egg")

func _deffered_spawn_egg():
	var egg = egg_scene.instantiate()
	egg.global_position = global_position
	get_parent().add_child(egg)
	egg = egg_scene.instantiate()
	egg.global_position = global_position + Vector2(100, 0)
	get_parent().add_child(egg)
	egg = egg_scene.instantiate()
	egg.global_position = global_position + Vector2(-100, 0)
	get_parent().add_child(egg)

func spawn_sheald():
	boost_system.apply_boost("wall_shield")
	
func spawn_dragon_sheald():
	boost_system.apply_boost("dragon_sheald")
	
func regen_health(reg_hp):
	for i in range(5):
		hp = min(hp + reg_hp, max_hp)
		update_hp.emit(hp)
		var parts = green_particles.instantiate()
		parts.global_position = global_position
		get_parent().add_child(parts)
		parts.emitting = true
		parts.one_shot = true
		await get_tree().create_timer(2).timeout
		
func spawn_feathers(count):
	boost_system.apply_boost("spawn_feathers")
	for i in range(count):
		var feather = feather_scene.instantiate()
		feather.global_position = global_position
		get_parent().call_deferred("add_child", feather)

func spawn_companion():
	call_deferred("_deferred_spawn_companion")

func _deferred_spawn_companion():
	var companion = companion_scene.instantiate()
	add_child(companion)

func spawn_electro_ball():
	call_deferred("deffered_spawn_electro_ball")
	
func deffered_spawn_electro_ball():
	var electro_ball = electro_ball_scene.instantiate()
	electro_ball.global_position = global_position
	get_parent().add_child(electro_ball)

func spawn_lava_balls():
	call_deferred("deffered_spawn_lava_balls")
	
func deffered_spawn_lava_balls():
	for i in range(5):
		var lava_ball = lava_ball_scene.instantiate()
		
		var angle = randf() * 2 * PI
		var distance = randf_range(20, 80)
		
		var offset = Vector2(cos(angle), sin(angle)) * distance
		lava_ball.global_position = global_position + offset
		
		if lava_ball is RigidBody2D:
			lava_ball.linear_velocity = Vector2(cos(angle), sin(angle)) * randf_range(100, 200)

		get_parent().add_child(lava_ball)

func spawn_meteors():
	var bottom_edge = get_viewport().get_visible_rect().size.y
	var width_screen = get_viewport().get_visible_rect().size.x
	var meteor_position = [
		Vector2(width_screen/10, bottom_edge), Vector2(width_screen*6/10, bottom_edge),
		Vector2(width_screen*2/10, bottom_edge), Vector2(width_screen*7/10, bottom_edge), 
		Vector2(width_screen*3/10, bottom_edge), Vector2(width_screen*8/10, bottom_edge),
		Vector2(width_screen*4/10, bottom_edge), Vector2(width_screen*9/10, bottom_edge),
		Vector2(width_screen*5/10, bottom_edge)
	]
	
	var selected_indices = []
	var quantity = 9
	
	while selected_indices.size() < quantity:
		var random_index = randi() % meteor_position.size()
		if not selected_indices.has(random_index):
			selected_indices.append(random_index)
	
	call_deferred("_deferred_spawn_meteors", meteor_position, selected_indices, quantity)

func _deferred_spawn_meteors(positions: Array, indices: Array, count: int):
	for i in range(count):
		var meteor = meteor_scene.instantiate()
		meteor.global_position = positions[indices[i]]
		get_parent().add_child(meteor)

func _deferred_spawn_shield():
	if current_shield and is_instance_valid(current_shield):
		current_shield.queue_free()
		current_shield = null
	current_shield = wall_sheald.instantiate()
	add_child(current_shield)
	current_shield.position = Vector2(0, -100)

func _deferred_spawn_dragon_shield():
	if current_shield and is_instance_valid(current_shield):
		current_shield.queue_free()
		current_shield = null
	current_shield = dragon_sheald.instantiate()
	add_child(current_shield)
	current_shield.position = Vector2(0, -124)
	
#---End---

func _on_cd_shot_timer_timeout():
	cd_shot = true
	
func stop(time):
	first_speed = 0
	speed = 0
	await get_tree().create_timer(time).timeout
	first_speed = 1000
	speed = first_speed

func phone_vibrate(intensity := 50):
	if Engine.has_singleton("HapticFeedback"):
		var h = Engine.get_singleton("HapticFeedback")
		h.vibrate(intensity)

func freeze(freeze_power: int = 1):
	isFreeze = true
	
	if freeze_stage >= max_freeze_stage:
		return
	elif freeze_imunitet:
		return 
		
	if freeze_stage == 0:
		original_speed = first_speed
	
	for i in range(freeze_power):
		if freeze_stage >= max_freeze_stage:
			break
			
		freeze_stage += 1
		
		take_damage.emit(hp, freeze_stage)
		
		if freeze_stage < max_freeze_stage:
			var slow_factor = 1.0 - (freeze_stage * (1.0 / max_freeze_stage))
			first_speed = original_speed * slow_factor
			speed = first_speed
			
			var blue_intensity = (freeze_stage * (1.0 / max_freeze_stage))
			$AnimatedSprite2D.modulate = Color(1.0 - blue_intensity, 1.0 - blue_intensity, 1.0)

			$AnimatedSprite2D.speed_scale = original_anim_speed * slow_factor
		else:
			first_speed = 0
			speed = 0
			
			follow_mouse = false
			stop_laser()
			
			$AnimatedSprite2D.modulate = Color(0, 0, 1.0)
			$AnimatedSprite2D.stop()
			$AnimatedSprite2D.speed_scale = 0.1
			
			cd_shot = false
			
			freeze_timer.stop()
			full_freeze_timer.start(3.0)
			break
	
	if freeze_timer:
		freeze_timer.stop()
	if freeze_stage > 0 and freeze_stage < max_freeze_stage:
		freeze_timer.start(2.0)
	
	freeze_particles_show()

func _on_freeze_timer_timeout():
	if freeze_stage > 0:
		freeze_stage -= 1
		
		if freeze_stage > 0:
			# Частичное восстановление
			var slow_factor = 1.0 - (freeze_stage * (1.0 / max_freeze_stage))
			first_speed = original_speed * slow_factor
			speed = first_speed
			
			# Обновляем цвет
			var blue_intensity = freeze_stage * (freeze_stage * (1.0 / max_freeze_stage))
			$AnimatedSprite2D.modulate = Color(1.0 - blue_intensity, 1.0 - blue_intensity, 1.0)
			
			# Восстанавливаем скорость анимации
			$AnimatedSprite2D.speed_scale = original_anim_speed * slow_factor
			
			freeze_timer.start(2.0)
		else:
			# Полное восстановление
			_unfreeze()

func _on_full_freeze_timeout():
	_unfreeze()

func _unfreeze():
	isFreeze = false
	freeze_stage = 0
	first_speed = original_speed
	speed = first_speed
	
	$AnimatedSprite2D.modulate = Color.WHITE
	$AnimatedSprite2D.speed_scale = original_anim_speed
	$AnimatedSprite2D.play()
	
	cd_shot = true

func freeze_particles_show():
	var particles = freeze_particle_scene.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.emitting = true
	particles.one_shot = true
	await get_tree().create_timer(2).timeout
	particles.queue_free()

func apply_heat(power := 1):
	isHeat = true

	for i in range(power):
		if heat_stage >= max_heat_stage:
			break

		heat_stage += 1
		handle_heat_effects()

		heat_timer.stop()
		heat_timer.start(heat_duration)

func handle_heat_effects():
	var red_intensity = heat_stage * (1.0 / max_heat_stage)
	if not isFreeze:
		$AnimatedSprite2D.modulate = Color(1.0, 1.0 - red_intensity, 1.0 - red_intensity)
	print(heat_stage)
	match heat_stage:
		1:
			shot_spread = 0.15
		2:
			isClin = false
			shot_spread = 0.3
		3:
			isClin = true
			shot_spread = 0.45
		4:
			shot_spread = 0.6
		5:
			shot_spread = 0.8

func _on_heat_timer_timeout():
	if heat_stage > 0:
		heat_stage -= 1
		handle_heat_effects()
		if heat_stage == 0:
			reset_heat()

func reset_heat():
	heat_stage = 0
	shot_spread = 0.0
	$AnimatedSprite2D.modulate = Color.WHITE

func show_clin_particles():
	var particles = clin_particles_scene.instantiate()
	particles.global_position = global_position + Vector2(0, -100)
	get_parent().add_child(particles)
	particles.emitting = true
	particles.one_shot = true
	await get_tree().create_timer(2).timeout
	particles.queue_free()

func apply_hot_oil():
	_unfreeze()
	freeze_imunitet = true
	hot_oil_timer.start()

func _on_hot_oil_timeout():
	freeze_imunitet = false

func apply_fire_extinguisher():
	reset_heat()
	isHeat = false

func apply_battery():
	cd_shot_timer.stop()
	speed *= 2
	cd_shot_timer.start(0.1)
	await get_tree().create_timer(3.0).timeout
	cd_shot_timer.stop()
	speed = first_speed
	cd_shot_timer.start(0.3)

func apply_health_kit():
	for i in range(10):
		hp = min(hp + 10, max_hp)
		update_hp.emit(hp)
		var parts = green_particles.instantiate()
		parts.global_position = global_position
		get_parent().add_child(parts)
		parts.emitting = true
		parts.one_shot = true
		await get_tree().create_timer(2).timeout

func apply_smoke_grenade():
	var smoke = preload("res://scene/rashodniki/smoke_grenade/smoke_grenade.tscn").instantiate()
	smoke.global_position = global_position
	add_child(smoke)

func apply_grenade():
	var grenade = preload("res://scene/rashodniki/grenade/grenade.tscn").instantiate()
	grenade.global_position = global_position
	add_child(grenade)

func apply_grenade_green():
	var grenade = preload("res://scene/rashodniki/grenade/grenade_green.tscn").instantiate()
	grenade.global_position = global_position
	add_child(grenade)

func apply_grenade_contact():
	var grenade = preload("res://scene/rashodniki/grenade/grenade_contact.tscn").instantiate()
	grenade.global_position = global_position
	add_child(grenade)
