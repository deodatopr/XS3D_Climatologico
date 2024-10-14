class_name GDs_Cam_Manager extends Node

@export_group("Components")
#@export var worldEnv : WorldEnvironment
@export var movement : GDs_CamMovement
@export var pivot_cam : Node3D
@export var cam : Node3D

@export_group("Configurations")
@export var cr_cam_config_bottom : GDs_CR_Cam_ModeConfig
@export var cr_cam_config_top : GDs_CR_Cam_ModeConfig

func _ready():
	Initialize(ENUMS.Cam_Mode.Bottom)

func Initialize(_modeToIntializeCam : int):
	APPSTATE.camMode = _modeToIntializeCam
	
	#Update in realtime if CR is changed
	cr_cam_config_bottom.changed.connect(_UpdatedCamConfig_Bottom)
	cr_cam_config_top.changed.connect(_UpdatedCamConfig_Top)
	
	#if APPSTATE.camMode == ENUMS.Cam_Mode.Bottom:
		#movement.Initialize(cam,pivot_cam, cr_cam_config_bottom,worldEnv)
	#else:
		#movement.Initialize(cam,pivot_cam, cr_cam_config_top,worldEnv)
		
	if APPSTATE.camMode == ENUMS.Cam_Mode.Bottom:
		movement.Initialize(cam,pivot_cam, cr_cam_config_bottom)
	else:
		movement.Initialize(cam,pivot_cam, cr_cam_config_top)
		
	
func _input(event):
	if event.is_action_pressed("3DMove_ChangeCamMode"):
		if APPSTATE.camMode == ENUMS.Cam_Mode.Bottom:
			_ChangeMode(ENUMS.Cam_Mode.Top)
		else:
			_ChangeMode(ENUMS.Cam_Mode.Bottom)
			
			
func _ChangeMode(_changeTo : int):
	APPSTATE.camMode = _changeTo
	if _changeTo == ENUMS.Cam_Mode.Bottom:
		movement.SetModeConfig(cr_cam_config_bottom)
	else:
		movement.SetModeConfig(cr_cam_config_top)

func _UpdatedCamConfig_Bottom():
	movement.OnUpdateCRCam(cr_cam_config_bottom)
	
func _UpdatedCamConfig_Top():
	movement.OnUpdateCRCam(cr_cam_config_top)
