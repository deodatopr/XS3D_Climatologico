class_name GDs_CR_Cam_Config extends Resource
@export_category("Pivot dist")
@export_range(10,120)var bot_pivotDist: float:
	set(value):
		bot_pivotDist = value
		emit_changed()
@export_category("Height")
@export_range(10,120)var bot_height: float:
	set(value):
		bot_height = value
		emit_changed()
@export_range(10,120)var top_height: float:
	set(value):
		top_height = value
		emit_changed()
@export_range(5,20)var height_speed: float:
	set(value):
		height_speed = value * 10
		emit_changed()
@export_category("Fov")
@export_range(30,120)var bot_fov: float:
	set(value):
		bot_fov = value
		emit_changed()
@export_range(30,120)var top_fov: float:
	set(value):
		top_fov = value
		emit_changed()
@export_category("Tilt")
@export_range(10,120)var bot_tilt: float:
	set(value):
		bot_tilt = -value
		emit_changed()
@export_range(10,120)var top_tilt: float:
	set(value):
		top_tilt = -value
		emit_changed()
@export_category("Movement")
@export_range(10,120)var bot_mov_speed: float:
	set(value):
		bot_mov_speed = value
		emit_changed()
@export_range(10,120)var top_mov_speed: float:
	set(value):
		top_mov_speed = value
		emit_changed()
@export var boundings_X_min : float:
	set(value):
		boundings_X_min = value
		emit_changed()
@export var boundings_X_max : float:
	set(value):
		boundings_X_max = value
		emit_changed()
@export var boundings_Z_min : float:
	set(value):
		boundings_Z_min = value
		emit_changed()
@export var boundings_Z_max : float:
	set(value):
		boundings_Z_max = value
		emit_changed()
@export_category("Rotation Horizontal")
@export var bot_rotHor_speed : float:
	set(value):
		bot_rotHor_speed = value
		emit_changed()
@export var top_rotHor_speed : float:
	set(value):
		top_rotHor_speed = value
		emit_changed()
