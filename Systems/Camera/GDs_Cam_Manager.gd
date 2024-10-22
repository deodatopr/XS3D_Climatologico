class_name GDs_Cam_Manager extends Node

@export_group("SCENE REFERENCES")
@export var aerialMovement : GDs_AerialMovement
@export var pivot_cam : Node3D
@export var cam : Node3D

@export_group("AERIAL CAMERA")
@export var valuesInRuntime : bool

@export_subgroup("Movements")
@export var aerial_height : float = 300
@export var aerial_flying_speed: float = 20
@export var aerial_rotation_speed : float = 20
@export var aerial_curveAccel : Curve
@export var aerial_curveDecel : Curve
@export var aerial_distPivotsRot : float = 50

@export_subgroup("Camera")
@export var aerial_camRotAngle : float = 70
@export var aerial_camRot_min: float = 45
@export var aerial_camRot_max : float = 80
@export var aerial_camRot_Speed : float = 50

@export var aerial_fov : float = 100
@export var aerial_fov_min : float = 90
@export var aerial_fov_max : float = 110

@export_group("DRON CAMERA")
@export var test : float

signal OnCamChangeMode

func _ready():
	Initialize(ENUMS.Cam_Mode.Bottom)
	
func _process(_delta : float):
	if valuesInRuntime:
		aerialMovement.UpdateCamConfig()

func Initialize(_modeToIntializeCam : int):
	APPSTATE.camMode = _modeToIntializeCam
	aerialMovement.Initialize(self)
