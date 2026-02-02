extends "res://scene/bases/enemy_base/enemy_base.gd"

var shot_kd = randf_range(0, 2)
@export var laser_scene: PackedScene
var can_laser_attack = true
var is_attacking = false

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 100
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y - 800
	direction = 1 if randi() % 2 == 0 else -1
	hp = 50
	speed = 300
	coin_chance = 20
	size = 50

func _on_shot_timeout():
	if can_laser_attack and not is_attacking:
		start_laser_attack()

func start_laser_attack():
	is_attacking = true
	can_laser_attack = false
	
	speed_h = 0
	
	await get_tree().create_timer(1).timeout
	var laser = laser_scene.instantiate()
	laser.position = position + Vector2(0, 414)
	add_child(laser)
	
	await get_tree().create_timer(1).timeout
	laser.queue_free()
	
	direction = 1 if randi() % 2 == 0 else -1
	speed_h = 100
	is_attacking = false
	can_laser_attack = true
