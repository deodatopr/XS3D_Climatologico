extends Node
class_name GDs_Orchestrator_Main

@export var splash : GDs_Splash
@export var curtain : GDs_Curtain
@export var serviceData_manager : GDs_DataService_Manager
@export var lvlPerfiles : GDs_Perf_Manager

func _ready():
	#SPLASH
	splash.Show()
	await get_tree().create_timer(0.1).timeout
	
	#ENDPOINT
	serviceData_manager.Initialize()
	serviceData_manager.MakeRequest_GetAllEstaciones()
	serviceData_manager.OnDataRefresh.connect(lvlPerfiles.OnDataRefresh)	
	
	#PERFILES
	lvlPerfiles.Initialize(serviceData_manager)
	await serviceData_manager.OnDataRefresh
