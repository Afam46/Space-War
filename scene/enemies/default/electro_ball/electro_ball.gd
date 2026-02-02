extends RigidBody2D

var speed = 200
var damage = 10
var player: Node2D

func _ready():
	$AnimatedSprite2D.animation = "create"
	if $AnimatedSprite2D.sprite_frames:
		$AnimatedSprite2D.sprite_frames.set_animation_loop("create", false)
	$AnimatedSprite2D.play()
	await $AnimatedSprite2D.animation_finished
	
	$AnimatedSprite2D.animation = "fly"
	$AnimatedSprite2D.play()
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		linear_velocity = direction * speed
	else:
		linear_velocity = Vector2.DOWN * speed

func slow():
	pass

func _on_timer_timeout():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
