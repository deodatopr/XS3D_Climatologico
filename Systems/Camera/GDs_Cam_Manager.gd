class_name GDs_Cam_Manager extends Node

@export_group("SCENE REFERENCES")
@export var aerialMovement : GDs_AerialMovement
@export var pivot_cam : Node3D
@export var cam : Node3D

@export_group("AERIAL CAMERA")
@export var valuesInRuntime : bool

@export_subgroup("Movements")
@export var aerial_height : float = 800
@export var aerial_flying_speed: float = 50
@export var aerial_rotation_speed : float = .3
@export var aerial_curveAccel : Curve
@export var aerial_curveDecel : Curve
@export var aerial_distPivotsRot : float = 50

@export_subgroup("Camera")
@export var aerial_camRotAngle : float = 50
@export var aerial_camRot_min: float
@export var aerial_camRot_max : float
@export var aerial_camRot_Speed : float = 50

@export var aerial_fov : float = 100
@export var aerial_fov_min : float = 90
@export var aerial_fov_max : float = 110
@export_range(0,1) var aerial_fov_transition : float

@export_group("DRON CAMERA")
@export var test : float

var aerialConfig : GDs_AerialConfig = GDs_AerialConfig.new()

signal OnCamChangeMode

func _ready():
	Initialize(ENUMS.Cam_Mode.Bottom)
	
func _process(_delta : float):
	if valuesInRuntime:
		cam.global_position.y = aerial_height
		cam.fov = lerpf(aerial_fov_min,aerial_fov_max, aerial_fov_transition)
		
		GetCamAereoValues()
		aerialMovement.UpdateCamConfig(aerialConfig)

func Initialize(_modeToIntializeCam : int):
	APPSTATE.camMode = _modeToIntializeCam
	GetCamAereoValues()
	aerialMovement.Initialize(cam,pivot_cam,aerialConfig)
	
func GetCamAereoValues():
	aerialConfig.height = aerial_height
	aerialConfig.rotation = -aerial_camRotAngle
	aerialConfig.distPivotsRot = aerial_distPivotsRot
	
	aerialConfig.curvAcceleration = aerial_curveAccel
	aerialConfig.curvDeceleration = aerial_curveDecel
	
	aerialConfig.movement_speed = aerial_flying_speed
	aerialConfig.rotHor_speed = aerial_rotation_speed
	aerialConfig.rotVert_min = aerial_camRot_min
	aerialConfig.rotVert_max = aerial_camRot_max
	
	aerialConfig.fov_initial = aerial_fov
	aerialConfig.fov_min = aerial_fov_min
	aerialConfig.fov_max = aerial_fov_max
	aerialConfig.fov_transition = aerial_fov_transition
	
	
