extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var enemy_bullet_scene: PackedScene

func _ready():
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/2
	speed_h = 150
	direction = 1 if randi() % 2 == 0 else -1
	hp = 200
	coin_chance = 100
	boost_chance = 0
	size = 20
	if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)
	
	set_physics_process(false)

func activate_head_movement():
	speed_h = 150
	set_physics_process(true)
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", false)

func _on_shot_timeout():
	shot()

func shot():
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(26, 72)
	get_parent().add_child(bullet)
	await get_tree().create_timer(0.3).timeout
	bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(-26, 72)
	get_parent().add_child(bullet)
	await get_tree().create_timer(0.3).timeout
	$Shot.start()
