extends RigidBody2D

var hp: int = 1
var coin_chance: float = 0
var size: int = 0
# Переменные скорости
var speed: float = 0
var angular_speed: float = 0
var rotate_speed: float = 0
# Переменные для движения h
var speed_h: float = 0
var direction: float = 0
var screen_size
var target_y_position: float = 0
# Переменные после смерти
var speed_after_death: float = 0
var angular_speed_after_death: float = 0
var rotate_speed_after_death: float = 0

@export var particle_scene: PackedScene
@export var coin_scene: PackedScene
	
func _physics_process(delta):
	move_and_collide(Vector2.DOWN * speed * delta)
	if angular_speed:
		rotation += angular_speed * delta
		var velocity = Vector2.DOWN.rotated(rotation) * rotate_speed
		position += velocity * delta
	
	if target_y_position > 0:
		move_h(delta)

func move_h(delta):
	if position.y > target_y_position:
		speed = 0
		move_and_collide(Vector2.RIGHT * direction * delta * speed_h)

		if position.x >= screen_size.x - size:
			direction = -1
		elif position.x <= 50:
			direction = 1
			
func destroy():
	hp -= 1
	hit_animation()
	
	if particle_scene:
		call_deferred("show_particles")

	if coin_scene:
		call_deferred("drop_coin")
		
	if hp <= 0:
		die()

func die():
	$AnimatedSprite2D.animation = "death"
	
	if $AnimatedSprite2D.sprite_frames:
		$AnimatedSprite2D.sprite_frames.set_animation_loop("death", false)
		
	$AnimatedSprite2D.play()

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	speed = speed_after_death
	speed_h = 0
	angular_speed = angular_speed_after_death
	rotate_speed = rotate_speed_after_death
	
	drop_boost()
	
	await $AnimatedSprite2D.animation_finished
	queue_free()

func show_particles():
	var particles = particle_scene.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.emitting = true
	particles.one_shot = true

func drop_coin():
	if randf() * 100 <= coin_chance:
		var coin = coin_scene.instantiate()
		coin.global_position = global_position
		get_parent().add_child(coin)

func drop_boost():
	pass

func hit_animation():
	if hp >= 1:
		$AnimatedSprite2D.modulate = Color.RED
		await get_tree().create_timer(0.3).timeout
		$AnimatedSprite2D.modulate = Color.WHITE
	else:
		$AnimatedSprite2D.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		$AnimatedSprite2D.modulate = Color.WHITE
