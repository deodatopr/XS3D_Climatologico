extends Node
@export var anim:AnimationPlayer
@export var duration:float

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(duration).timeout
	anim.stop()	
