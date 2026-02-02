extends RigidBody2D

var hp: int = 10
var damage = randi_range(5, 15)
var coin_chance: float = 0
var boost_chance: float = 5
var size: int = 0
var sound_type = 1

var freeze_stage := 0
var max_freeze_stage = 3
var isFreeze = false
var is_dead := false

var original_speed: float = 0.0
var original_speed_h: float = 0.0
var original_angular: float = 0.0
var original_rotate: float = 0.0
var original_anim_speed := 1.0

# Переменные скорости
var speed: float = 0
var angular_speed: float = 0
var rotate_speed: float = 0
var speed_h: float = 0
var direction: float = 0
var screen_size
var target_y_position
# Переменные после смерти
var speed_after_death: float = 0
var angular_speed_after_death: float = 0
var rotate_speed_after_death: float = 0
var plyr_damage: int

@export var particle_scene: PackedScene
@export var coin_scene: PackedScene
@export var freeze_particle_scene: PackedScene
@export var damage_number_scene: PackedScene

@onready var death_sounds_small = [
	preload("res://aasounds/explosion_small_1.wav"),
	preload("res://aasounds/explosion_small_2.wav"),
	preload("res://aasounds/explosion_small_3.wav"),
]

@onready var death_sounds_medium = [
	preload("res://aasounds/explosion_med_1.wav"),
	preload("res://aasounds/explosion_med_2.wav"),
	preload("res://aasounds/explosion_med_3.wav"),
]

@onready var death_sounds_big = [
	preload("res://aasounds/explosion_big_1.wav"),
	preload("res://aasounds/explosion_big_2.wav"),
	preload("res://aasounds/explosion_big_3.wav"),
]

@onready var death_sounds_boss = [
	preload("res://aasounds/explosion_boss_1.wav"),
	preload("res://aasounds/explosion_boss_2.wav"),
	preload("res://aasounds/explosion_boss_3.wav"),
]

@onready var hit_sounds = [
	preload("res://aasounds/metal_hit/metal_hit_1.wav"),
	preload("res://aasounds/metal_hit/metal_hit_2.wav"),
	preload("res://aasounds/metal_hit/metal_hit_3.wav"),
	preload("res://aasounds/metal_hit/metal_hit_4.wav")
]

func _ready():
	screen_size = get_viewport_rect().size
	original_speed = speed
	original_speed_h = speed_h
	original_angular = angular_speed
	original_rotate = rotate_speed
	original_anim_speed = $AnimatedSprite2D.speed_scale

func enemy():
	pass

func _physics_process(delta):
	move_enemy(delta)
	
func move_enemy(delta):
	if speed:
		move_and_collide(Vector2.DOWN * speed * delta)
	if target_y_position > 0:
		move_h(delta)

func move_h(delta):
	if position.y >= target_y_position:
		speed = 0
		move_and_collide(Vector2.RIGHT * direction * delta * speed_h)

	if position.x >= screen_size.x - size:
		position.x = screen_size.x - size
		direction = -1
	elif position.x <= size:
		position.x = size
		direction = 1

func destroy(player_damage):
	plyr_damage = player_damage
	hp -= plyr_damage
	
	play_hit_sound()
	
	if particle_scene:
		call_deferred("show_particles")
	
	call_deferred("hit_anim")
		
	if hp <= 0:
		die()

func play_hit_sound():
	var sfx = hit_sounds[randi() % hit_sounds.size()]
	$HitSound.stream = sfx
	$HitSound.pitch_scale = randf_range(0.95, 1.05)
	$HitSound.play()

func hit_anim():
	show_damage_number()
	if not isFreeze:
		hit_red_anim()

func hit_red_anim():
	$AnimatedSprite2D.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	$AnimatedSprite2D.modulate = Color.WHITE
	
func show_damage_number():
	if damage_number_scene:
		var damage_number = damage_number_scene.instantiate()
		
		# Позиция над игроком
		var spawn_position = global_position + Vector2(randf_range(-10, 10), -60)
		
		get_parent().add_child(damage_number)
		damage_number.setup(plyr_damage, spawn_position)

func die():
	if is_dead:
		return
		
	is_dead = true
	
	play_death_sound()
	
	if has_node("FreezeTimer"):
		$FreezeTimer.stop()
	if has_node("FullFreezeTimer"):
		$FullFreezeTimer.stop()
	if has_node("Shot"):
		$Shot.stop()
	
	freeze_stage = 0
	$AnimatedSprite2D.speed_scale = original_anim_speed
	$AnimatedSprite2D.modulate = Color.WHITE
	
	$AnimatedSprite2D.animation = "death"
	$AnimatedSprite2D.sprite_frames.set_animation_loop("death", false)
	$AnimatedSprite2D.play()

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)

	speed = speed_after_death
	speed_h = 0
	angular_speed = angular_speed_after_death
	rotate_speed = rotate_speed_after_death

	if coin_scene:
		call_deferred("drop_coin")

	drop_boost()
	
	await $AnimatedSprite2D.animation_finished
	queue_free()

func play_death_sound():
	var sound_list
	
	match sound_type:
		0:
			sound_list = death_sounds_small
		1:
			sound_list = death_sounds_medium
		2:
			sound_list = death_sounds_big
		3:
			sound_list = death_sounds_boss
	
	if sound_list.size() == 0:
		return
	
	var random_sound = sound_list[randi() % sound_list.size()]
	
	$Death.stream = random_sound
	$Death.play()

func show_particles():
	var particles = particle_scene.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.emitting = true
	particles.one_shot = true
	await get_tree().create_timer(2).timeout
	if particles:
		particles.queue_free()

func drop_coin():
	if randf() * 100 <= coin_chance:
		var coin = coin_scene.instantiate()
		coin.global_position = global_position
		get_parent().add_child(coin)

func drop_boost():
	if randf() * 100 <= boost_chance:
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
			var is_unlocked = GameData.available_boosts[boost_id].unlocked
			var has_scene = boost_id in boost_scene_map
			
			if is_unlocked and has_scene:
				unlocked_boosts.append(boost_id)
				
		if unlocked_boosts.is_empty():
			return
		
		var random_boost_id = unlocked_boosts[randi() % unlocked_boosts.size()]
		var boost_scene = boost_scene_map[random_boost_id]
		
		call_deferred("_deferred_spawn_boost", boost_scene, position)

func _deferred_spawn_boost(boost_scene: PackedScene, spawn_position: Vector2):
	var boost = boost_scene.instantiate()
	boost.position = spawn_position
	get_parent().add_child(boost)

# ——————————————
# СИСТЕМА ЗАМОРОЗКИ
# ——————————————

func freeze(freeze_power = 1):
	if is_in_group("bosses"):
		return
		
	if is_in_group("freezing_enemies"):
		return
		
	if is_dead:
		return
		
	isFreeze = true

	if freeze_stage >= max_freeze_stage:
		return
	
	for i in range(freeze_power):
		if freeze_stage == 0:
			original_speed = speed
			original_speed_h = speed_h
			original_angular = angular_speed
			original_rotate = rotate_speed
		
		freeze_stage += 1
		
		if freeze_stage < max_freeze_stage:
			# Частичная заморозка
			var slow_factor = 1.0 - (freeze_stage * (1.0 / max_freeze_stage))
			speed = original_speed * slow_factor
			speed_h = original_speed_h * slow_factor
			angular_speed = original_angular * slow_factor
			rotate_speed = original_rotate * slow_factor
			
			# Синий цвет в зависимости от стадии
			var blue_intensity = (freeze_stage * (1.0 / max_freeze_stage))
			$AnimatedSprite2D.modulate = Color(1.0 - blue_intensity, 1.0 - blue_intensity, 1.0)
			
			# Замедляем анимацию только для обычной анимации
			if $AnimatedSprite2D.animation != "death":
				$AnimatedSprite2D.speed_scale = original_anim_speed * slow_factor
			
			$FreezeTimer.start()
			freeze_particles_show()
		else:
			speed = 50
			speed_h = 0
			angular_speed = 0
			rotate_speed = 0
			
			# Синий цвет при полной заморозке
			$AnimatedSprite2D.modulate = Color(0, 0, 1.0)
			
			# Останавливаем анимацию только если это не смерть
			if $AnimatedSprite2D.animation != "death":
				$AnimatedSprite2D.stop()
				$AnimatedSprite2D.speed_scale = 0.1
			if has_node("Shot") and $Shot:
				$Shot.stop()
			
			$FreezeTimer.stop()
			$FullFreezeTimer.start()
			freeze_particles_show()

func _on_FullFreezeTimer_timeout():
	if is_dead:
		return
	# После полной заморозки - мгновенное восстановление
	_unfreeze()

func _on_FreezeTimer_timeout():
	if is_dead:
		return
	if freeze_stage > 0:
		freeze_stage -= 1
		
		if freeze_stage > 0:
			var slow_factor = 1.0 - (freeze_stage * (1.0 / max_freeze_stage))
			speed = original_speed * slow_factor
			speed_h = original_speed_h * slow_factor
			angular_speed = original_angular * slow_factor
			rotate_speed = original_rotate * slow_factor
			
			# Обновляем цвет
			var blue_intensity = (freeze_stage * (1.0 / max_freeze_stage))
			$AnimatedSprite2D.modulate = Color(1.0 - blue_intensity, 1.0 - blue_intensity, 1.0)
			
			# Восстанавливаем скорость анимации
			if $AnimatedSprite2D.animation != "death":
				$AnimatedSprite2D.speed_scale = original_anim_speed * slow_factor
			
			$FreezeTimer.start()
		else:
			# Полное восстановление
			_unfreeze()

func _unfreeze():
	isFreeze = false
	freeze_stage = 0
	speed = original_speed
	speed_h = original_speed_h
	angular_speed = original_angular
	rotate_speed = original_rotate
	
	# ВОССТАНАВЛИВАЕМ ВСЁ
	$AnimatedSprite2D.modulate = Color.WHITE
	$AnimatedSprite2D.speed_scale = original_anim_speed
	
	if $AnimatedSprite2D.animation != "death":
		$AnimatedSprite2D.play()
	if has_node("Shot") and $Shot and not is_dead:
		$Shot.start()

func freeze_particles_show():
	var particles = freeze_particle_scene.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.emitting = true
	particles.one_shot = true
	await get_tree().create_timer(2).timeout
	particles.queue_free()

func shake(duration := 0.2, strength := 5):
	var tween = create_tween()
	var original_pos = position

	tween.set_loops(int(duration / 0.05))
	tween.tween_callback(func():
		position = original_pos + Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
	).set_delay(0.05)

	tween.finished.connect(func():
		position = original_pos
	)
