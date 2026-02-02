extends Area2D

@export var ice_bullet_scene: PackedScene
var damage = 10

func _ready():
	$CollisionShape2D.set_deferred("disabled", true)

func _on_boss_8_tail_shot():
	$AnimatedSprite2D.animation = "rotate"
	$AnimatedSprite2D.play()
	
	while $AnimatedSprite2D.frame < 3:
		await get_tree().process_frame
	
	$AnimatedSprite2D.pause()
	shot()
	await get_tree().create_timer(0.4).timeout
	shot()
	await get_tree().create_timer(0.4).timeout
	shot()
	await get_tree().create_timer(0.4).timeout
	
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.play_backwards() 
	
	while $AnimatedSprite2D.frame > 1:
		await get_tree().process_frame
	
	$AnimatedSprite2D.stop()
	
func shot():
	var bullet_positions = [
		{"pos": Vector2(40, 160), "rot": 0},
		{"pos": Vector2(80, 124), "rot": -PI/8},
		{"pos": Vector2(0, 124), "rot": PI/8},
	]
	
	for bullet_data in bullet_positions:
		var ice_bullet = ice_bullet_scene.instantiate()
		
		var local_pos = bullet_data["pos"]
		var global_pos = to_global(local_pos)
		
		ice_bullet.global_position = global_pos
		ice_bullet.set_direction_from_enemy(bullet_data["rot"])
		get_parent().get_parent().add_child(ice_bullet)

func hit_anim():
	$AnimatedSprite2D.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	$AnimatedSprite2D.modulate = Color.WHITE


func _on_boss_8_tail_sheald():
	$AnimatedSprite2D.animation = "rotate"
	$AnimatedSprite2D.play()
	
	while $AnimatedSprite2D.frame < 3:
		await get_tree().process_frame
	
	$AnimatedSprite2D.pause()
	
	$CollisionShape2D.set_deferred("disabled", false)

	await get_tree().create_timer(4).timeout
	
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.play_backwards() 
	
	while $AnimatedSprite2D.frame > 1:
		await get_tree().process_frame
	
	$AnimatedSprite2D.stop()
	
	$CollisionShape2D.set_deferred("disabled", true)

func _on_body_entered(body):
	if body and body.has_method("make_enemy_bullet"):
		body.make_enemy_bullet()
