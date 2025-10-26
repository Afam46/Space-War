extends Area2D

signal hit(hp)

@export var bullet_scene: PackedScene
@export var strong_bullet_scene: PackedScene
@export var spark: PackedScene

@onready var double_bullet_timer = $DoubleBulletTimer
@onready var strong_bullet_timer = $StrongBulletTimer

var speed = 400
var screen_size
var max_hp = 30
var hp = max_hp
var coins = 0
var strong_bullet = false
var quantity_bullet = 1
var boost_time = 5

func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play()

func _process(delta):
	if Input.is_action_just_pressed("shot"):
		shot()
		
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	
	position += velocity.normalized() * delta * speed
	position = position.clamp(Vector2.ZERO, screen_size)


func _on_body_entered(body):
	if body:
		if body.has_method("instant_death"):
			body.instant_death()
		elif body.has_method("destroy"):
			body.destroy()
	hp -= 1
	hit.emit(hp)
	
	var particles = spark.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.emitting = true
	particles.one_shot = true
	
	if hp >= 1:
		$AnimatedSprite2D.modulate = Color.RED
		await get_tree().create_timer(0.3).timeout
		$AnimatedSprite2D.modulate = Color.WHITE
	else:
		$AnimatedSprite2D.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		$AnimatedSprite2D.modulate = Color.WHITE
	if hp <= 0:
		$AnimatedSprite2D.animation = "death"
		$AnimatedSprite2D.play()
	
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)
		speed = 0
	
		await get_tree().create_timer(0.6).timeout
		hide()


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func shot():
	if not strong_bullet:
		for i in range(quantity_bullet):
			var bullet = bullet_scene.instantiate()
			bullet.global_position = global_position + Vector2(0, -78)
			add_child(bullet)
			await get_tree().create_timer(0.1).timeout
	else:
		for i in range(quantity_bullet):
			var bullet = strong_bullet_scene.instantiate()
			bullet.global_position = global_position + Vector2(0, -78)
			add_child(bullet)
			await get_tree().create_timer(0.1).timeout

func restart():
	show()
	hp = max_hp
	speed = 400
	$AnimatedSprite2D.animation = "fly"
	
func add_coins(value):
	coins += value
	print(coins)

func res_health(health):
	hp = min(hp + health, max_hp)

func make_strong_bullet():
	strong_bullet = true
	strong_bullet_timer.start(boost_time)

func make_double_bullet():
	quantity_bullet = 2
	double_bullet_timer.start(boost_time)
   
func _on_double_bullet_timer_timeout():
	quantity_bullet = 1

func _on_strong_bullet_timer_timeout():
	strong_bullet = false
