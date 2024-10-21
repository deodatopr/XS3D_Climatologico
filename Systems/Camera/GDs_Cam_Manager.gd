class_name GDs_Cam_Manager extends Node

@export_group("Refs")
@export var camAereaMovement : GDs_CamAereaMovement
@export var pivot_cam : Node3D
@export var cam : Node3D

@export_group("Cam Dron Config")
@export var updateValuesInRuntime : bool

@export var camAerea_height_initial : float
@export var camAerea_tilt_initial : float
@export var camAerea_movement_speed: float
@export var camAerea_rotHor_speed : float

#FOV
@export_subgroup("FOV")
@export var camAerea_fov_initital : float
@export var camAerea_fov_min : float
@export var camAerea_fov_max : float
@export_range(0,1) var camAerea_fov_transition : float



var camAereaConfig : GDs_CamAereaConfig = GDs_CamAereaConfig.new()

signal OnCamChangeMode

func _ready():
	Initialize(ENUMS.Cam_Mode.Bottom)
	
func _process(_delta : float):
	if updateValuesInRuntime:
		cam.global_position.y = camAerea_height_initial
		cam.fov = lerpf(camAerea_fov_min,camAerea_fov_max, camAerea_fov_transition)
		
		GetCamAereoValues()
		camAereaMovement.UpdateCamConfig(camAereaConfig)

func Initialize(_modeToIntializeCam : int):
	APPSTATE.camMode = _modeToIntializeCam
	GetCamAereoValues()
	camAereaMovement.Initialize(cam,pivot_cam,camAereaConfig)
	
func GetCamAereoValues():
	camAereaConfig.movement_speed = camAerea_movement_speed
	camAereaConfig.rotHor_speed = camAerea_rotHor_speed
	
	camAereaConfig.fov_initial = camAerea_fov_initital
	camAereaConfig.fov_min = camAerea_fov_min
	camAereaConfig.fov_max = camAerea_fov_max
	camAereaConfig.fov_transition = camAerea_fov_transition
	
	camAereaConfig.height_initial = camAerea_height_initial
	camAereaConfig.tilt_initial = -camAerea_tilt_initial
	
