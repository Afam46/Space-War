extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var rocket_scene: PackedScene
@export var meteor_scene: PackedScene

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = 200
	direction = randf_range(-1,1)
	speed = 200
	speed_h = 200
	coin_chance = 20
	hp = 30
	size = 60
	

func _on_shot_timeout():
	shot()

func shot():
	var rocket = rocket_scene.instantiate()
	rocket.global_position = global_position + Vector2(74, 112)
	get_parent().add_child(rocket)
	
	rocket = rocket_scene.instantiate()
	rocket.global_position = global_position + Vector2(-74, 112)
	get_parent().add_child(rocket)

func spawn_meteor():
	$Shot.stop()
	$SpawnMeteor.stop()
	var meteor_position = [
		Vector2(40, -31), Vector2(110, -31), Vector2(180, -31), 
		Vector2(250, -31), Vector2(320, -31), Vector2(390, -31),
		Vector2(460, -31), Vector2(530, -31), Vector2(600, -31),
		Vector2(670, -31)
	]
	
	var selected_indices = []
	
	var quantity = randi_range(4, 8)
	
	while selected_indices.size() < quantity:
		var random_index = randi() % meteor_position.size()
		if not selected_indices.has(random_index):
			selected_indices.append(random_index)
	
	for i in range(quantity):
		var meteor = meteor_scene.instantiate()
		meteor.global_position = meteor_position[selected_indices[i]]
		get_parent().add_child(meteor)
		
	await get_tree().create_timer(2.5).timeout
	$Shot.start()
	$SpawnMeteor.start()


func _on_spawn_meteor_timeout():
	spawn_meteor()
