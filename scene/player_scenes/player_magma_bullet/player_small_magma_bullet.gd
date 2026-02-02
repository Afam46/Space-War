extends Area2D

var speed = 600
var damage = randi_range(8, 12) + GameData.damage_bonus
var angular_speed = PI
var direction = randf_range(-1,1)

func _physics_process(delta):
	position += Vector2(1 * direction, -1) * delta * speed
	rotation += angular_speed * delta
	
func instant_death():
	queue_free()
	
func destroy(_damage):
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body:
		if body.has_method("destroy"):
			body.destroy(damage)
	queue_free()
