extends TextureRect

@export var parent: Node
@export var parent_property_for_current_direction: String = "rotation"
@export_range(0.01, 0.5) var _lerp_speed: float = 0.1

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	var curr_val = material.get_shader_parameter("dir")
	material.set_shader_parameter(
		"dir", lerp_angle(curr_val, -parent.get(parent_property_for_current_direction).y, _lerp_speed)
	)
