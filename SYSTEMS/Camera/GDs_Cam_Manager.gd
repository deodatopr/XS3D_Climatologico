class_name GDs_Cam_Manager extends Node

@export_group("Components")
@export var movement : GDs_CamMovement
@export var pivot_movement : Node3D
@export var cam : Node3D

@export_group("Configurations")
@export var cr_cam_Inclinada : GDs_CR_Cam_ModeConfig
@export var cr_cam_Top : GDs_CR_Cam_ModeConfig

func _ready():
	Initialize()

func Initialize():
	#Update in realtime if CR is changed
	cr_cam_Inclinada.changed.connect(_UpdatedCamConfig)
	cr_cam_Top.changed.connect(_UpdatedCamConfig)
	
	movement.Initialize(cam,pivot_movement)
	movement.SetModeConfig(cr_cam_Inclinada)
	
func _UpdatedCamConfig():
	if APPSTATE.camMode == ENUMS.Cam_Mode.Inclinada:
		movement.SetModeConfig(cr_cam_Inclinada)
	else:
		movement.SetModeConfig(cr_cam_Top)
