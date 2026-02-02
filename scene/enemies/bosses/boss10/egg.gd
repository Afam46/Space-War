extends "res://scene/bases/enemy_base/enemy_base.gd"

var rand_angular_speed
@export var companion_scene: PackedScene
@export var dirrection = Vector2.DOWN

@onready var meteor_sounds = [
	preload("res://aasounds/meteor_destroy_1.wav"),
	preload("res://aasounds/meteor_destroy_2.wav"),
	preload("res://aasounds/meteor_destroy_3.wav")
]

func _ready():
	randomize()
	max_freeze_stage = 5
	hp = 50
	coin_chance = 0
	speed = 150
	speed_after_death = 75
	rand_angular_speed = randf_range(PI/8, PI)
	angular_speed = rand_angular_speed
	angular_speed_after_death = rand_angular_speed
	boost_chance = 0

func _physics_process(delta):
	move_and_collide(dirrection * speed * delta)
	rotation += angular_speed * delta

func play_death_sound():
	var sfx = AudioStreamPlayer.new()
	sfx.stream = meteor_sounds[randi() % meteor_sounds.size()]
	sfx.volume_db = -8
	get_tree().current_scene.add_child(sfx)
	sfx.play()
	sfx.connect("finished", sfx.queue_free)

func instant_death():
	die()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy(player_damage):
	plyr_damage = player_damage
	hp -= plyr_damage

	if particle_scene:
		call_deferred("show_particles")
	
	if freeze_stage == 0:
		call_deferred("hit_anim")
		
	if hp <= 0:
		super.die()

var death

func die():
	spawn_companions()
	super.die()

func spawn_companions():
	$AnimatedSprite2D.animation = "spawn"
	$AnimatedSprite2D.sprite_frames.set_animation_loop("spawn", false)
	$AnimatedSprite2D.play()

	await $AnimatedSprite2D.animation_finished

	var companion = companion_scene.instantiate()
	companion.global_position = global_position
	get_parent().add_child(companion)
	
	companion = companion_scene.instantiate()
	companion.global_position = global_position + Vector2(40, 0)
	get_parent().add_child(companion)
	
	companion = companion_scene.instantiate()
	companion.global_position = global_position + Vector2(-40, 0)
	get_parent().add_child(companion)

func speed_up():
	speed = -250
	speed_after_death = -325
	await get_tree().create_timer(2).timeout
	speed = 150
	speed_after_death = 75

func full_speed_up():
	speed = -850
	speed_after_death = -925
