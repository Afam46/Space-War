extends RigidBody2D

@export var particle_scene: PackedScene
@export var magma_bullet_scene: PackedScene

var	speed = 250
var	speed_after_death = 200
var	angular_speed = PI
var damage = randi_range(30, 35)

@onready var meteor_sounds = [
	preload("res://aasounds/meteor_destroy_1.wav"),
	preload("res://aasounds/meteor_destroy_2.wav"),
	preload("res://aasounds/meteor_destroy_3.wav")
] 
	
func _physics_process(delta):
	var collision = move_and_collide(Vector2.UP * delta * speed)
	rotation += angular_speed * delta
	if collision:
		var collider = collision.get_collider()
		if collider:
			if collider.has_method("destroy"):
				collider.destroy(damage)
			die()

var death = false
var isSplit = false

func die():
	if death:
		return
	death = true
	$AnimatedSprite2D.animation = "death"
	
	if $AnimatedSprite2D.sprite_frames:
		$AnimatedSprite2D.sprite_frames.set_animation_loop("death", false)
		
	$AnimatedSprite2D.play()
	
	play_death_sound()
	
	show_particles()
	
	if $CollisionShape2D:
		$CollisionShape2D.call_deferred("set_disabled", true)
	
	speed = speed_after_death
	
	if not isSplit:
		split()

	await $AnimatedSprite2D.animation_finished
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func show_particles():
	var particles = particle_scene.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.emitting = true
	particles.one_shot = true

func speed_up():
	speed = -200
	speed_after_death = -300
	await get_tree().create_timer(2).timeout
	speed = 200
	speed_after_death = 100

func full_speed_up():
	speed = -800
	speed_after_death = -900

func play_death_sound():
	var sfx = AudioStreamPlayer.new()
	sfx.stream = meteor_sounds[randi() % meteor_sounds.size()]
	sfx.volume_db = -8
	get_tree().current_scene.add_child(sfx)
	sfx.play()
	sfx.connect("finished", sfx.queue_free)

func split():
	isSplit = true
	var magma_bullet = magma_bullet_scene.instantiate()
	magma_bullet.global_position = global_position + Vector2(-50,0)
	get_parent().call_deferred("add_child", magma_bullet)
	
	magma_bullet = magma_bullet_scene.instantiate()
	magma_bullet.global_position = global_position + Vector2(50,0)
	get_parent().call_deferred("add_child", magma_bullet)

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()
