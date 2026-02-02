extends Area2D

var min_speed = 350
var max_speed = 550
var velocity = Vector2.ZERO
var damage = randi_range(15,25)

func _ready():
	var speed = randf_range(min_speed, max_speed)
	
	var angle = randf() * TAU
	velocity = Vector2(cos(angle), sin(angle)) * speed

	var anims = ["sharp1", "sharp2", "sharp3", "sharp4", "sharp5"]
	$AnimatedSprite2D.animation = anims[randi() % anims.size()]
	$AnimatedSprite2D.play()

	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if not is_instance_valid(body):
		return
		
	if body.has_method("destroy"):
		body.destroy(damage)
		
	if is_instance_valid(self):
		queue_free()
