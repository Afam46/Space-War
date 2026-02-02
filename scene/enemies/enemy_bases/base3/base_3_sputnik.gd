extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var laser_scene: PackedScene
var can_laser_attack = true
var is_attacking = false

func _ready():
	hp = 500
	max_freeze_stage = 15
	speed = 100
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y / 3
	sound_type = 3
	coin_chance = 100

func _on_shot_timeout():
	if position.y >= target_y_position:
		if can_laser_attack and not is_attacking:
			start_laser_attack()

func start_laser_attack():
	is_attacking = true
	can_laser_attack = false
	
	var laser = laser_scene.instantiate()
	laser.position = position + Vector2(0, 556)
	add_child(laser)
	
	await get_tree().create_timer(3).timeout
	laser.queue_free()
	
	is_attacking = false
	can_laser_attack = true
