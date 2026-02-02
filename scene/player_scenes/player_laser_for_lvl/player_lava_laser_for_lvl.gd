extends Area2D

@export var particle_scene: PackedScene

var speed = 200
var speed_after_death = 100
var damage = 50

@onready var meteor_sounds = [
	preload("res://aasounds/meteor_destroy_1.wav"),
	preload("res://aasounds/meteor_destroy_2.wav"),
	preload("res://aasounds/meteor_destroy_3.wav")
] 
	
func _physics_process(delta):
	position += Vector2.UP * delta * speed

func _on_body_entered(body):
	if body.has_method("set_direction_from_enemy"):
		hit_red_anim()
		body.queue_free()
	elif body.has_method("destroy"):
		body.destroy(damage)
		die()

func hit_red_anim():
	$AnimatedSprite2D.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	$AnimatedSprite2D.modulate = Color.WHITE

func die():
	$AnimatedSprite2D.animation = "death"
	
	if $AnimatedSprite2D.sprite_frames:
		$AnimatedSprite2D.sprite_frames.set_animation_loop("death", false)
		
	$AnimatedSprite2D.play()
	
	play_death_sound()
	
	show_particles()
	
	if $CollisionShape2D:
		$CollisionShape2D.call_deferred("set_disabled", true)
	
	speed = speed_after_death

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

	# Удалить звук после окончания
	sfx.connect("finished", sfx.queue_free)
