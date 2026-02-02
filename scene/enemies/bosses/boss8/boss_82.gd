extends "res://scene/bases/enemy_base/enemy_base.gd"

var coin_count = 7
@export var ice_scene : PackedScene
signal enemy_died
var speed_move = 100
var detach_weapons = false

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/5
	direction = 1 if randi() % 2 == 0 else -1
	speed = 100
	speed_h = 100
	hp = 1000
	damage = randi_range(20, 35)
	size = 80
	boost_chance = 0
	$WeaponBoss822.get_node("AnimatedSprite2D").scale.x = -4
	await get_tree().create_timer(3).timeout
	$Shot.start()
	sound_type = 3

func hit_anim():
	if not detach_weapons:
		if hp <= 250:
			call_deferred("move_weapons_to_parent")
		else:
			$WeaponBoss812.hit_red_anim()
			$WeaponBoss81.hit_red_anim()
	super.hit_anim()

func move_weapons_to_parent():
	detach_weapons = true
	speed_h = 0
	speed_move = 0
	speed = 0
	var parent = get_parent()
	
	if has_node("WeaponBoss822") and parent:
		var weapon1 = $WeaponBoss822
		remove_child(weapon1)
		parent.call_deferred("add_child", weapon1)
		weapon1.global_position = global_position
		weapon1.use_rockets(82)
	
	if has_node("WeaponBoss82") and parent:
		var weapon2 = $WeaponBoss82
		remove_child(weapon2)
		parent.call_deferred("add_child", weapon2)
		weapon2.global_position = global_position
		weapon2.use_rockets(82)

func _on_shot_timeout():
	shot()

func shot():
	var ice = ice_scene.instantiate()
	ice.global_position = global_position + Vector2(-2, 166)
	ice.boost_chance = 0
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
		speed_h = speed_move

var death = false

func die():
	if death:
		return
	death = true
	super.die()
	call_deferred("drop_coins") 
	enemy_died.emit()

func drop_coins():
	for i in range(coin_count):
		var coin = coin_scene.instantiate()
		
		var angle = randf() * 2 * PI
		var distance = randf_range(20, 80)
		
		var offset = Vector2(cos(angle), sin(angle)) * distance
		coin.global_position = global_position + offset
		
		if coin is RigidBody2D:
			coin.linear_velocity = Vector2(cos(angle), sin(angle)) * randf_range(100, 200)
		
		get_parent().add_child(coin)
