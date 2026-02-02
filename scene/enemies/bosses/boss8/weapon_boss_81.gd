extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var enemy_ice_bullet_scene: PackedScene
var isRocket = false
var freeze_power = 5

func _ready():
	$AnimatedSprite2D.play()
	hp = 200
	speed = 0
	speed_h = 0
	coin_chance = 0
	damage = randi_range(30, 50)
	set_physics_process(false)

func use_rockets(boss_type = 81):
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", false)
	$Shot.stop()
	isRocket = true
	speed = 100
	angular_speed = randf_range(-PI, PI)
	if boss_type == 81:
		rotate_speed = 300
	else:
		rotate_speed = -300
	
	set_physics_process(true)

func _physics_process(delta):
	move_and_collide(Vector2.DOWN * speed * delta)
	rotation += angular_speed * delta
	var velocity = Vector2.DOWN.rotated(rotation) * rotate_speed
	position += velocity * delta

func instant_death():
	set_physics_process(false)
	super.die()

func hit_animation():
	super.hit_anim()

func _on_shot_timeout():
	shot()

func shot():
	var bullet = enemy_ice_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(-6, 88)
	get_parent().get_parent().add_child(bullet)


func _on_boss_82_enemy_died():
	instant_death()


func _on_boss_81_enemy_died():
	instant_death()
