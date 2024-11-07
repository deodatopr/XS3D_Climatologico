class_name GDs_Orquestrator_Sector extends Node

@export_enum("Sky","Fly") var initCamMode : int = 0
@export var cameraDrones : GDs_Cam_Manager
@export var ppeGlitch : GDs_Glitch
@export var fly : GDs_VistaFly
@export var sky : GDs_Vista_Sky
@export var menu : GDs_UI_Manager

var dataService : GDs_DataService_Manager

func Initialize(_dataService : GDs_DataService_Manager):
	dataService = _dataService
	
	cameraDrones.Initialize(initCamMode)
	ppeGlitch.Initialize()
	fly.Initialize(cameraDrones)
	menu.Initialize(dataService,fly,cameraDrones)
