class_name GDs_Orchestrator_Main extends Node

@export var splash : GDs_Splash
@export var curtain : GDs_Curtain
@export var scenes_manager : GDs_Scenes_Manager
@export var serviceData_manager : GDs_DataService_Manager

func _ready():
	APPSTATE.EP_GetAllEstaciones_RequestType = ENUMS.EP_RequestType.From_Debug_Random
	
	#SPLASH
	splash.Show()
	await get_tree().create_timer(0.1).timeout
	
	#ENDPOINT
	serviceData_manager.Initialize()
	serviceData_manager.MakeRequest_GetAllEstaciones()
	await serviceData_manager.OnDataRefresh
	
	#ESCENAS
	scenes_manager.Initialize()
