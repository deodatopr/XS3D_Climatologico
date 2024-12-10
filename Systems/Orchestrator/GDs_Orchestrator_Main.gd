class_name GDs_Orchestrator_Main extends Node
@export_enum("Sector1","Sector2","Sector3","Sector4","Sector6","Random") var sitioInicial: int
@export var splash : GDs_Splash
@export var curtain : GDs_Curtain
@export var scenes_manager : GDs_Scenes_Manager
@export var dataService_manager : GDs_DataService_Manager
@export var crLocalEstaciones : GDs_CR_LocalSitios

func _ready():
	APPSTATE.EP_GetAllEstaciones_RequestType = ENUMS.EP_RequestType.From_Simulado
	var sitioToStart : int = scenes_manager.GetRndIdSite()

	match sitioInicial:
		0: sitioToStart = 1
		1: sitioToStart = 2
		2: sitioToStart = 3
		3: sitioToStart = 4
		4: sitioToStart = 6
		_: 
			var arraySitios : Array[int] = [1,2,4,6]
			sitioToStart = arraySitios.pick_random()

	
	APPSTATE.currntIdSitio = sitioToStart
	
	#SPLASH
	splash.Show()
	await get_tree().create_timer(0.1).timeout
	
	#ENDPOINT
	dataService_manager.Initialize()
	dataService_manager.MakeRequest_GetAllEstaciones()
	
	#ESCENAS
	scenes_manager.Initialize(dataService_manager,curtain)
	
	await splash.OnFinishSplash
	
	scenes_manager.GoToSector(sitioToStart,true)
	
	#Send data to refresh inmediatly
	SIGNALS.OnRefresh.emit()
