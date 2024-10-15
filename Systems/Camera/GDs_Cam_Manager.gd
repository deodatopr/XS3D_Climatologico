class_name GDs_Cam_Manager extends Node

@export_group("Components")
#@export var worldEnv : WorldEnvironment
@export var movement : GDs_CamMovement
@export var pivot_cam : Node3D
@export var cam : Node3D

@export_group("Configurations")
@export var cr_cam_config : GDs_CR_Cam_Config

func _ready():
	Initialize(ENUMS.Cam_Mode.Bottom)

func Initialize(_modeToIntializeCam : int):
	APPSTATE.camMode = _modeToIntializeCam
	
	#Update in realtime if CR is changed
	cr_cam_config.changed.connect(_UpdatedCamConfig)
		
	movement.Initialize(cam,pivot_cam, cr_cam_config)
		
	
func _input(event):
	if event.is_action_pressed("3DMove_ChangeCamMode"):
		if APPSTATE.camMode == ENUMS.Cam_Mode.Bottom:
			_ChangeMode(ENUMS.Cam_Mode.Top)
		else:
			_ChangeMode(ENUMS.Cam_Mode.Bottom)

func _ChangeMode(_changeTo : int):
	APPSTATE.camMode = _changeTo
	movement.SetModeConfig()

func _UpdatedCamConfig():
	movement.UpdateProperties()
	
