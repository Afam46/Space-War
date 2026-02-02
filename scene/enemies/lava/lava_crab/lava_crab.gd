extends "res://scene/bases/enemy_base/enemy_base.gd"

var back = false
var origin_target_y_position = 0

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 120
	direction = randf_range(-1,1)
	max_freeze_stage = 15
	hp = 200
	damage = 40
	speed = 300
	screen_size = get_viewport_rect().size
	target_y_position = randi_range(screen_size.y/1.8, screen_size.y/2.2)
	origin_target_y_position = target_y_position
	coin_chance = 20
	size = 20

func move_h(delta):
	if (not back and position.y >= target_y_position) \
	or (back and position.y <= target_y_position):

		speed = 0
		move_and_collide(Vector2.RIGHT * direction * speed_h * delta)

		if position.x >= screen_size.x - size:
			position.x = screen_size.x - size
			direction = -1
		elif position.x <= size:
			position.x = size
			direction = 1

func die():
	speed = 0
	super.die()

func _on_dash_timeout():
	dash()
	
func instant_death():
	super.die()

func dash():
	if freeze_stage > 0:
		super._unfreeze()
	back = false
	speed = 1000
	target_y_position = screen_size.y/1.2
	await get_tree().create_timer(1.5).timeout
	if freeze_stage > 0:
		super._unfreeze()
	back = true
	speed = -1000
	target_y_position = origin_target_y_position

func _on_visible_on_screen_notifier_2d_screen_exited():
	super.die()
