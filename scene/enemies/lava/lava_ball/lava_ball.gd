extends "res://scene/bases/enemy_base/enemy_base.gd"

var rand_angular_speed
@export var magma_bullet_scene: PackedScene

@onready var meteor_sounds = [
	preload("res://aasounds/meteor_destroy_1.wav"),
	preload("res://aasounds/meteor_destroy_2.wav"),
	preload("res://aasounds/meteor_destroy_3.wav")
]

func _ready():
	randomize()
	damage = randi_range(30,35)
	hp = 50
	max_freeze_stage = 5
	coin_chance = 50
	speed = 250
	speed_after_death = 200
	rand_angular_speed = randf_range(PI/8, PI)
	angular_speed = rand_angular_speed
	angular_speed_after_death = rand_angular_speed

func _physics_process(delta):
	move_and_collide(Vector2.DOWN * speed * delta)
	rotation += angular_speed * delta

func play_death_sound():
	var sfx = AudioStreamPlayer.new()
	sfx.stream = meteor_sounds[randi() % meteor_sounds.size()]
	sfx.volume_db = -8
	get_tree().current_scene.add_child(sfx)
	sfx.play()

	sfx.connect("finished", sfx.queue_free)

var isSplit = false

func instant_death():
	super.die()
	if not isSplit:
		split()

func split():
	isSplit = true
	var magma_bullet = magma_bullet_scene.instantiate()
	magma_bullet.global_position = global_position + Vector2(-50,0)
	magma_bullet.isCreate = false
	get_parent().call_deferred("add_child", magma_bullet)
	
	magma_bullet = magma_bullet_scene.instantiate()
	magma_bullet.global_position = global_position + Vector2(50,0)
	magma_bullet.isCreate = false
	get_parent().call_deferred("add_child", magma_bullet)

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
		die()
		if not isSplit:
			split()
