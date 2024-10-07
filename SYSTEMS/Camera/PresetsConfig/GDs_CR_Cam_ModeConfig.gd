class_name GDs_CR_Cam_ModeConfig extends Resource

@export var initialHeight : float:
	set(value):
		initialHeight = value
		emit_changed()
@export_range(0,360,1,"degress") var initialInclination : float:
	set(value):
		initialInclination = -value
		emit_changed()
@export var rotVert_allow : bool:
	set(value):
		rotVert_allow = value
		emit_changed()
@export_group("Panning")
@export_range(3,15) var pan_acceleration : float:
	set(value):
		pan_acceleration = value
		emit_changed()
@export_range(3,15) var pan_max_acceleration : float:
	set(value):
		pan_max_acceleration = value
		emit_changed()
@export_range(5,20) var pan_deceleration : float:
	set(value):
		pan_deceleration = value
		emit_changed()
@export_group("Rotation")
@export_range(.5,1.5) var rotHor_speed : float:
	set(value):
		rotHor_speed = value
		emit_changed()
@export_range(0.01,.3) var rotHor_deceleration : float:
	set(value):
		rotHor_deceleration = value
		emit_changed()
@export_range(10,30) var rotVert_speed : float:
	set(value):
		rotVert_speed = value
		emit_changed()
@export_group("Height")
@export_range(2,8) var height_speed:
	set(value):
		height_speed = value*100
		emit_changed()
@export_range(10,30)var height_deceleration:
	set(value):
		height_deceleration = value
		emit_changed()
