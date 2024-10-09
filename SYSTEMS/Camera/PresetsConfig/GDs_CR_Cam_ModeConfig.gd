class_name GDs_CR_Cam_ModeConfig extends Resource

@export var initialHeight : float:
	set(value):
		initialHeight = value
		emit_changed()
@export_range(0,360,1,"degress") var initialInclination : float:
	set(value):
		initialInclination = -value
		emit_changed()
@export_group("Panning")
@export_range(3,15) var pan_acceleration : float:
	set(value):
		pan_acceleration = value
		emit_changed()
@export_range(5,15) var pan_max_acceleration : float:
	set(value):
		pan_max_acceleration = value
		emit_changed()
@export_range(5,20) var pan_deceleration : float:
	set(value):
		pan_deceleration = value
		emit_changed()
@export_group("Rotation")
@export var rotVert_allow : bool:
	set(value):
		rotVert_allow = value
		emit_changed()
@export_range(15,50) var rotVert_speed : float:
	set(value):
		rotVert_speed = value
		emit_changed()
@export_range(15,50) var rotVert_maxRotFromInitial : float:
	set(value):
		rotVert_maxRotFromInitial = value
		emit_changed()
@export var rotHor_allow : bool:
	set(value):
		rotHor_allow = value
		emit_changed()
@export_range(.5,1.5) var rotHor_speed : float:
	set(value):
		rotHor_speed = value
		emit_changed()
@export_range(0.01,.3) var rotHor_deceleration : float:
	set(value):
		rotHor_deceleration = value
		emit_changed()
@export_group("Height")
@export_range(2,15) var height_speed:
	set(value):
		height_speed = value*100
		emit_changed()
@export_range(10,50)var height_deceleration:
	set(value):
		height_deceleration = value
		emit_changed()
@export_range(1,50,1)var height_limit_min:
	set(value):
		height_limit_min = value
		emit_changed()
@export_range(1,50,1)var height_limit_max:
	set(value):
		height_limit_max = value
		emit_changed()
@export_group("FOV")
@export var fov_changeByHeight : bool:
	set(value):
		fov_changeByHeight = value
		emit_changed()
@export var fov_static : float:
	set(value):
		fov_static = value
		emit_changed()
@export_range(30,120)var fov_height_min : float:
	set(value):
		fov_height_min = value
		emit_changed()
@export_range(30,120)var fov_height_max : float:
	set(value):
		fov_height_max = value
		emit_changed()
@export_group("Boundings")
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

		
