extends Path2D

func _ready():
	update_path_size()

func update_path_size():
	var screen_size = get_viewport().get_visible_rect().size
	
	curve.add_point(Vector2(40, 0))
	curve.add_point(Vector2(screen_size.x - 40, 0))
	
	self.curve = curve
