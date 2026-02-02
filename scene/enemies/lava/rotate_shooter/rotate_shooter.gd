extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var enemy_bullet_scene: PackedScene
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 120
	direction = randf_range(-1,1)
	max_freeze_stage = 7
	hp = 120
	speed = 100
	screen_size = get_viewport_rect().size
	target_y_position = randi_range(screen_size.y/7, screen_size.y/4)
	coin_chance = 20
	size = 20

func move_enemy(delta):
	linear_velocity = Vector2.DOWN * speed
	look_at(player.global_position)
		
	super.move_enemy(delta)

func _on_shot_timeout():
	shot()

func shot():
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = $SpawnPoint1.global_position
	bullet.set_direction_from_enemy(rotation - PI/2)
	get_parent().add_child(bullet)
	
	bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = $SpawnPoint2.global_position
	bullet.set_direction_from_enemy(rotation - PI/2)
	get_parent().add_child(bullet)
