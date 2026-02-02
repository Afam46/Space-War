extends Marker2D

var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x/2, screen_size.y/1.5)
