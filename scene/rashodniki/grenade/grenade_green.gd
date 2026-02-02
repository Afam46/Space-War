extends Area2D

var speed = 200
var angular_speed = PI
var damage = randi_range(100,120)
@export var spark_grenade_scene: PackedScene 

@onready var death_sounds_medium = [
	preload("res://aasounds/explosion_med_1.wav"),
	preload("res://aasounds/explosion_med_2.wav"),
	preload("res://aasounds/explosion_med_3.wav"),
]

func _ready():
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)

func _process(delta):
	position += Vector2.UP * speed * delta
	rotation += angular_speed * delta

func _on_life_time_timeout():
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", false)
	play_death_sound()
	show_boom()
	$AnimatedSprite2D.animation = "death"
	$AnimatedSprite2D.sprite_frames.set_animation_loop("death", false)
	$AnimatedSprite2D.play()
	speed = 0
	angular_speed = 0
	show_particles()
	await $AnimatedSprite2D.animation_finished
	queue_free()

func speed_up():
	speed = -200

func play_death_sound():
	var sfx = AudioStreamPlayer.new()
	sfx.stream = death_sounds_medium[randi() % death_sounds_medium.size()]
	sfx.volume_db = 20
	get_tree().current_scene.add_child(sfx)
	sfx.play()

	sfx.connect("finished", sfx.queue_free)

func _on_body_entered(body):
	if not is_instance_valid(body):
		return
	if body.has_method("destroy") and body.has_method("shake"):
		body.destroy(damage)
		body.shake(0.3, 8)

func show_boom():
	$BoomRadius.visible = true
	$BoomRadius.play("default")

	while $BoomRadius.frame < 5:
		await get_tree().process_frame
	
	$BoomRadius.pause()

func show_particles():
	var particles = spark_grenade_scene.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.emitting = true
	particles.one_shot = true
	await get_tree().create_timer(2).timeout
	particles.queue_free()
