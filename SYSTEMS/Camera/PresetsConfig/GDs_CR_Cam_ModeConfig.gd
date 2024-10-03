class_name GDs_CR_Cam_ModeConfig extends Resource

@export var inclination : float:
	set(value):
		inclination = value
		emit_changed()
@export_range(3,15) var speed_panning : float:
	set(value):
		speed_panning = value
		emit_changed()
@export_range(.5,1.5) var speed_rotHor : float:
	set(value):
		speed_rotHor = value
		emit_changed()
@export_range(5,15) var speed_zoom : float:
	set(value):
		speed_zoom = value
		emit_changed()
