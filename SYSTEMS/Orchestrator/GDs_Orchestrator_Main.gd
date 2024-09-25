extends Node
class_name GDs_Orchestrator_Main

@export var splash : GDs_Splash
@export var curtain : GDs_Curtain
@export var serviceData_manager : GDs_DataService_Manager
@export var lvlPerfiles : GDs_Perf_Manager

func _ready():
	print("0")
	#SPLASH
	splash.Show()
	await splash.OnFinishSplash
	
	print("1")
	#CURTAIN
	curtain.Show()
	await curtain.OnCurtainCovered
	print("2")
	
	#SERVICE DATA
	serviceData_manager.Initialize()
	print("2.1")
	
	#PERFILES
	lvlPerfiles.Initialize(serviceData_manager)
	print("2.2")
	
	#SEÑALES
	serviceData_manager.OnDataRefresh.connect(lvlPerfiles.OnDataRefresh)
	print("2.3")
	
	#REQUEST ENDPOINT
	serviceData_manager.MakeRequest_GetAllEstaciones()
	await serviceData_manager.OnDataRefresh
	print("3")
	
	curtain.Hide()
	await curtain.OnCurtainFinished
	print("4")
	
