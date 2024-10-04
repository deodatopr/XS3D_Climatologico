class_name GDs_CR_Cam_ModeConfig extends Resource

@export var initialHeight : float:
	set(value):
		initialHeight = value
		emit_changed()
@export_range(0,360,1,"degress") var initialInclination : float:
	set(value):
		initialInclination = -value
		emit_changed()
@export var allow_RotVert : bool:
	set(value):
		allow_RotVert = value
		emit_changed()
@export_group("Panning")
@export_range(3,15) var acceleration : float:
	set(value):
		acceleration = value
		emit_changed()
@export_range(3,15) var max_acceleration : float:
	set(value):
		max_acceleration = value
		emit_changed()
@export_range(5,20) var deceleration : float:
	set(value):
		deceleration = value
		emit_changed()
@export_group("Rotation")
@export_range(.5,1.5) var speed_rotHor : float:
	set(value):
		speed_rotHor = value
		emit_changed()
@export_range(10,30) var speed_rotVert : float:
	set(value):
		speed_rotVert = value
		emit_changed()
@export_group("Height")
@export_range(5,15) var speed_height : float:
	set(value):
		speed_height = value
		emit_changed()
