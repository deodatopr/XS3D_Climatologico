class_name GDs_Cam_Manager extends Node

@export_group("Components")
@export var movement : GDs_CamMovement
@export var pivot_cam : Node3D
@export var cam : Node3D

@export_group("Configurations")
@export var cr_cam_config : GDs_CR_Cam_ModeConfig

func _ready():
	Initialize()

func Initialize():
	#Update in realtime if CR is changed
	cr_cam_config.changed.connect(_UpdatedCamConfig)
	
	movement.Initialize(cam,pivot_cam, cr_cam_config)

func _UpdatedCamConfig():
	movement.OnUpdateCRCam(cr_cam_config)
