extends Control
@export var speed:float
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += delta * speed
