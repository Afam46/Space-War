extends "res://scene/bases/enemy_base/enemy_base.gd"

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	$AnimatedSprite2D.play()
	hp = 20
	speed = 700
	coin_chance = 100
	target_y_position = randf_range(200, 600)
	sound_type = 0

var rush = false
var rush_direction = Vector2.ZERO

func move_enemy(_delta):
	if not rush:
		linear_velocity = Vector2.DOWN * speed
		
		if player and is_instance_valid(player):
			look_at(player.global_position)
		
		if position.y >= target_y_position:
			prepare_rush()
	elif rush and freeze_stage != max_freeze_stage:
		linear_velocity = rush_direction * speed

func prepare_rush():
	linear_velocity = Vector2.ZERO
	
	if player and is_instance_valid(player):
		rush_direction = (player.global_position - global_position).normalized()
		look_at(player.global_position)
	
	await get_tree().create_timer(2.0).timeout
	rush = true

func instant_death():
	super.die()

func die():
	speed = 0
	super.die()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
