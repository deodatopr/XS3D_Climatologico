class_name GDs_CR_Cam_Config extends Resource

@export_category("CAMERAS")
@export_range(30,120)var top_fov: float:
	set(value):
		top_fov = value
		emit_changed()
@export_range(30,120)var bottom_fov: float:
	set(value):
		bottom_fov = value
		emit_changed()
@export_range(10,120)var top_height: float:
	set(value):
		top_height = value
		emit_changed()
@export_range(10,120)var bottom_height: float:
	set(value):
		bottom_height = value
		emit_changed()
@export_range(10,120)var bottom_focus: float:
	set(value):
		bottom_focus = value
		emit_changed()

@export_category("MOVEMENTS")
@export_range(0.5,3)var transition_speed: float:
	set(value):
		transition_speed = value
		emit_changed()
@export_range(10,120)var bottom_mov_speed: float:
	set(value):
		bottom_mov_speed = value
		emit_changed()
@export_range(10,120)var top_mov_speed: float:
	set(value):
		top_mov_speed = value
		emit_changed()
		
		
@export_category("LIMITS")
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
		
@export_category("DEBUG")
@export var debug_alwaysPivotMsh : bool:
	set(value):
		debug_alwaysPivotMsh = value
		emit_changed()
@export var debug_alwaysLookAt : bool:
	set(value):
		debug_alwaysLookAt = value
		emit_changed()
@export var debug_alwaysFov : bool:
	set(value):
		debug_alwaysFov = value
		emit_changed()