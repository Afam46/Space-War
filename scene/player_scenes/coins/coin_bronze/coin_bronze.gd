extends Area2D

@export var value: int = 1
var speed = 100

func _ready():
	$AnimatedSprite2D.play()
	area_entered.connect(_on_area_entered)

func _process(delta):
	position += Vector2.DOWN * delta * speed
	
func _on_area_entered(area):
	if area.is_in_group("player"):
		collect(area)

func collect(player):
	if player.has_method("add_coins"):
		player.add_coins(value)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func speed_up():
	speed = 400
	await get_tree().create_timer(2).timeout
	speed = 100
	
func full_speed_up():
	speed = 1000
