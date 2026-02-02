extends "res://scene/bases/enemy_base/enemy_base.gd"

signal enemy_died

@export var ice_scene: PackedScene

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 100
	direction = randf_range(-1,1)
	hp = 140
	speed = 250
	screen_size = get_viewport_rect().size
	target_y_position = randi_range(screen_size.y/7, screen_size.y/4)
	coin_chance = 20
	size = 20
	sound_type = 2

func _on_shot_timeout():
	shot()

func shot():
	var ice = ice_scene.instantiate()
	ice.global_position = global_position + Vector2(-2, 102)
	get_parent().add_child(ice)
	enemy_died.connect(ice._on_owner_died)
	await get_tree().process_frame
	if ice:
		ice.remove_from_group("bullets")
		ice.get_node("AnimatedSprite2D").play("create")
		ice.speed = 0
		ice.angular_speed = 0
		speed_h = 0
		$Shot.stop()
		await get_tree().create_timer(3).timeout
		$Shot.start()
		if ice:
			enemy_died.disconnect(ice._on_owner_died)
			ice.get_node("AnimatedSprite2D").play("idle")
			ice.speed = 300
			var rand_angular_speed = randf_range(PI/8, PI)
			ice.angular_speed = rand_angular_speed
			ice.angular_speed_after_death = rand_angular_speed
		speed_h = 250

func die():
	enemy_died.emit()
	super.die()
