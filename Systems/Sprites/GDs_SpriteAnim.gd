extends TextureRect

@export var animSpeed:= 10.0
@export var animLength:= 8
@export var animLoops:= 5
@export var spriteWidth:= 40
var sprite:AtlasTexture

func _ready() -> void:
	sprite = texture
	Play()

func Play():
	for j in animLength:
		await get_tree().create_timer(1/animSpeed).timeout
		sprite.region.position = Vector2(sprite.region.position.x + spriteWidth,sprite.region.position.y)
	sprite.region.position = Vector2(0,sprite.region.position.y)
	Play()
