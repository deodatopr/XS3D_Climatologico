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
	
	#ESCENAS
	scenes_manager.Initialize(dataService_manager,curtain)
	
	
	var rndIdSitio : int = scenes_manager.GetRndIdSite()
	#HACK: Iniciar siempre en el sitio 6
	rndIdSitio = 6
	scenes_manager.GoToSector(rndIdSitio)
	
	await scenes_manager.OnSectorLoaded
	await SIGNALS.OnSitioInitialized
	
	#Send data to refresh inmediatly
	SIGNALS.OnRefresh.emit()
	
