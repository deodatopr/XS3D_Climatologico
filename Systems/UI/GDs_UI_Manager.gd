extends Control

@export_group("Refs externas")
@export var dataService:GDs_DataService_Manager
@export_subgroup("Vista Drones")
@export var vistaSky:Control
@export var vistaFree:GDs_VistaFree
@export_subgroup("Refs Minimap")
@export var cam_manager:GDs_Cam_Manager
@export var pin_Sitio:Node3D
@export var mshTerrain:Node3D
@export_group("Refs internas")
@export var menuPerfiles:GDs_MenuPerfiles
@export var barraMenus:GDs_BarraMenus
@export var barraInfo:GDs_BarraInfo
@export var menuMapa:GDs_MenuMapa
@export var menuInfo:Control
@export var popUp:Control


var isFirstRun : bool = true
var tween:Tween

func _ready():
	#TODO: Quitar esto del ready y usar el Initialize en orquestador
	Initialize()

func _input(event):
	if event.is_action_pressed("UIShowInfo"):
		menuInfo.visible = true
		barraMenus.isFocusingMenu = false
		barraMenus.StopFocusOnMenus()
	if event.is_action_pressed("ui_cancel"):
		CloseInfoMenu()
		if not APPSTATE.popUpOpened:
			barraMenus.StopFocusOnMenus()
	
func Initialize():
	dataService.OnDataRefresh.connect(DataRefresh)
	
	barraMenus.BtnSitios.focus_entered.connect(CloseInfoMenu)
	barraMenus.BtnDatos.focus_entered.connect(CloseInfoMenu)
	barraMenus.BtnConfig.focus_entered.connect(CloseInfoMenu)
	barraMenus.BtnMapa.focus_entered.connect(CloseInfoMenu)
	
	vistaFree.cam_manager = cam_manager
	vistaFree.pinSitio = pin_Sitio
	vistaFree.map = mshTerrain
	vistaFree.Initialize()
	
	barraInfo.OnDataRefresh(dataService.estaciones[5]) #TODO conectar con orchestrator
	menuMapa.Initialize(dataService.estaciones,5)
	
	popUp.hide()

func CloseInfoMenu():
	if menuInfo.visible:
		menuInfo.visible = false

func DataRefresh():
	menuPerfiles.DataRefresh(dataService.estaciones)
