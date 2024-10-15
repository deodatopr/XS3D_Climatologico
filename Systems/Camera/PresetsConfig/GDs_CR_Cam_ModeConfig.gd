class_name GDs_CR_Cam_ModeConfig extends Resource

@export var initialHeight : float:
	set(value):
		initialHeight = value
		emit_changed()
@export_range(30,120)var fov: float:
	set(value):
		fov = value
		emit_changed()
@export var inclination: float:
	set(value):
		inclination = -value
		emit_changed()
@export var distFromPivotCam: float:
	set(value):
		distFromPivotCam = value
		emit_changed()

#region [ Height ]
@export_group("Height")
@export_range(1,50,1)var height_limit_bottom:
	set(value):
		height_limit_bottom = value
		emit_changed()
@export_range(1,50,1)var height_limit_top:
	set(value):
		height_limit_top = value
		emit_changed()
@export_range(20,100) var height_speed:
	set(value):
		height_speed = value * 10
		emit_changed()
@export_range(10,50)var height_deceleration:
	set(value):
		height_deceleration = value
		emit_changed()
#endregion

#region [ Panning ]
@export_group("Panning")
@export_range(15,50) var pan_acceleration : float:
	set(value):
		pan_acceleration = value
		emit_changed()
@export_range(10,30) var pan_max_acceleration : float:
	set(value):
		pan_max_acceleration = value
		emit_changed()
@export var pan_boostSpeed : float:
	set(value):
		pan_boostSpeed = value
		emit_changed()
@export_range(5,20) var pan_deceleration : float:
	set(value):
		pan_deceleration = value
		emit_changed()
		
@export_subgroup("Boundings")
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
#endregion

#region [ Rotation Hor ]
@export_group("Rotation Hor")
@export var rotHor_allow : bool:
	set(value):
		rotHor_allow = value
		emit_changed()
@export_range(.5,1.5) var rotHor_speed : float:
	set(value):
		rotHor_speed = value
		emit_changed()
@export_range(0.001,.3) var rotHor_deceleration : float:
	set(value):
		rotHor_deceleration = value
		emit_changed()
#endregion
