class_name GDs_CR_Cam_ModeConfig extends Resource

@export var initialHeight : float:
	set(value):
		initialHeight = value
		emit_changed()
@export var inclination : float:
	set(value):
		inclination = value
		emit_changed()
@export var allow_RotVert : bool:
	set(value):
		allow_RotVert = value
		emit_changed()
@export_group("Speeds")
@export_range(3,15) var speed_panning : float:
	set(value):
		speed_panning = value
		emit_changed()
@export_range(.5,1.5) var speed_rotHor : float:
	set(value):
		speed_rotHor = value
		emit_changed()
@export_range(10,30) var speed_rotVert : float:
	set(value):
		speed_rotVert = value
		emit_changed()
@export_range(5,15) var speed_zoom : float:
	set(value):
		speed_zoom = value
		emit_changed()
