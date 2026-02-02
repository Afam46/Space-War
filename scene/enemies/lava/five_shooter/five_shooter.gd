extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var enemy_bullet_scene: PackedScene

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 150
	max_freeze_stage = 10
	direction = 1 if randi() % 2 == 0 else -1
	hp = 300
	speed = 300
	screen_size = get_viewport_rect().size
	target_y_position = randi_range(screen_size.y/7, screen_size.y/4)
	coin_chance = 60
	size = 60
	sound_type = 2

func _on_fast_shot_timeout():
	fast_shot()

func _on_slow_shot_timeout():
	slow_shot()

func fast_shot():
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(-78, 82)
	get_parent().add_child(bullet)
	
	bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(78, 82)
	get_parent().add_child(bullet)
	
func slow_shot():
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(-30, 130)
	get_parent().add_child(bullet)
	
	bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(0, 90)
	get_parent().add_child(bullet)
	
	bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(30, 130)
	get_parent().add_child(bullet)

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
			if has_node("FastShot") and $FastShot:
				$FastShot.stop()
			if has_node("SlowShot") and $SlowShot:
				$SlowShot.stop()
			
			$FreezeTimer.stop()
			$FullFreezeTimer.start()
			freeze_particles_show()
