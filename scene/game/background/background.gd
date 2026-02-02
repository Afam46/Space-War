extends ParallaxBackground

@export var scroll_speed: float = 150.0
@export var normal_texture1: Texture2D
@export var normal_texture2: Texture2D
@export var freeze_texture1: Texture2D
@export var freeze_texture2: Texture2D
@export var lava_texture1: Texture2D
@export var lava_texture2: Texture2D

var target_speed := 150.0
var speed_change_time := 0.4
var speed_tween: Tween

func _ready():
	var viewport_size = get_viewport().get_visible_rect().size
	
	if has_node("ParallaxLayer/TextureRect"):
		var texture_rect1 = $ParallaxLayer/TextureRect
		texture_rect1.size = viewport_size
		
	if has_node("ParallaxLayer2/TextureRect"):
		var texture_rect2 = $ParallaxLayer2/TextureRect
		texture_rect2.size = viewport_size
		texture_rect2.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	
	set_normal_background()

func _process(delta):
	scroll_base_offset.y += scroll_speed * delta

func set_speed(new_speed: float, duration := 0.4):
	if speed_tween and speed_tween.is_valid():
		speed_tween.kill()

	speed_tween = create_tween()
	speed_tween.tween_property(self, "scroll_speed", new_speed, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Функции для смены фона
func set_freeze_background():
	if freeze_texture1 and has_node("ParallaxLayer/TextureRect"):
		$ParallaxLayer/TextureRect.texture = freeze_texture1
	if freeze_texture2 and has_node("ParallaxLayer2/TextureRect"):
		$ParallaxLayer2/TextureRect.texture = freeze_texture2

func set_normal_background():
	if normal_texture1 and has_node("ParallaxLayer/TextureRect"):
		$ParallaxLayer/TextureRect.texture = normal_texture1
	if normal_texture2 and has_node("ParallaxLayer2/TextureRect"):
		$ParallaxLayer2/TextureRect.texture = normal_texture2

func set_lava_background():
	if lava_texture1 and has_node("ParallaxLayer/TextureRect"):
		$ParallaxLayer/TextureRect.texture = lava_texture1
	if lava_texture2 and has_node("ParallaxLayer2/TextureRect"):
		$ParallaxLayer2/TextureRect.texture = lava_texture2
