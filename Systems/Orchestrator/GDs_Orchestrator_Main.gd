class_name GDs_Orchestrator_Main extends Node

@export var splash : GDs_Splash
@export var curtain : GDs_Curtain
@export var scenes_manager : GDs_Scenes_Manager
@export var dataService_manager : GDs_DataService_Manager
@export var crLocalEstaciones : GDs_CR_LocalEstaciones

func _ready():
	APPSTATE.EP_GetAllEstaciones_RequestType = ENUMS.EP_RequestType.From_Debug_Random
	
	#SPLASH
	splash.Show()
	await get_tree().create_timer(0.1).timeout
	
	#ENDPOINT
	dataService_manager.Initialize()
	dataService_manager.MakeRequest_GetAllEstaciones()
	await dataService_manager.OnDataRefresh
	
	#ESCENAS
	scenes_manager.Initialize(dataService_manager,curtain)
	scenes_manager.GoToSector(6)
	
