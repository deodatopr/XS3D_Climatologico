class_name GDs_UI_Manager extends Control

@export_group("INTERNAL REFERENCES")
@export var menuPerfiles:GDs_MenuPerfiles
@export var barraMenus:GDs_BarraMenus
@export var barraInfo:GDs_BarraInfo
@export var menuMapa:GDs_MenuMapa
@export var graficadora : GDs_Graficadora_Manager
@export var menuInfo:Control
@export var popUp:Control
@export var panelDebug:Control

var dataService : GDs_DataService_Manager
var vistaFly : GDs_VistaFly
var cam_manager:GDs_Cam_Manager

var isFirstRun : bool = true
var tween:Tween

func _input(event):
	if event.is_action_pressed("UI_Info"):
		if not APPSTATE.popUpOpened:
			menuInfo.visible = true
			menuPerfiles.GetCurrentFocus()
			barraMenus.StopFocusOnMenus()
			CloseDebugPanel()
			APPSTATE.menuUIOptionIsOpened = true
	if event.is_action_pressed("ui_cancel"):
		CloseInfoMenu()
		if not APPSTATE.popUpOpened:
			menuPerfiles.GetCurrentFocus()
			barraMenus.StopFocusOnMenus()
		if panelDebug.visible:
			panelDebug.visible = false
			APPSTATE.menuUIOptionIsOpened = false
	if event.is_action_pressed("UI_Simulado"):
		CloseInfoMenu()
		if not APPSTATE.popUpOpened:
			menuPerfiles.GetCurrentFocus()
			barraMenus.StopFocusOnMenus()
			panelDebug.visible = true
			APPSTATE.menuUIOptionIsOpened = true
				
			
	
func Initialize(_dataService : GDs_DataService_Manager,_vistaFree : GDs_VistaFly, _cam_manager:GDs_Cam_Manager):
	dataService = _dataService
	vistaFly = _vistaFree
	cam_manager = _cam_manager
	
	SIGNALS.OnRefresh.connect(DataRefresh)
	SIGNALS.OnRequestResult_Success.connect(barraInfo.OnRequestSuccess)
	SIGNALS.OnRequestResult_Error_Data.connect(barraInfo.OnRequestFailed)
	SIGNALS.OnRequestResult_Error_NoData.connect(barraInfo.OnRequestFailed)
	
	barraMenus.BtnSitios.focus_entered.connect(ClosePanels,)
	barraMenus.BtnDatos.focus_entered.connect(ClosePanels)
	barraMenus.BtnConfig.focus_entered.connect(ClosePanels)
	barraMenus.BtnMapa.focus_entered.connect(ClosePanels)
	
	vistaFly.Initialize(cam_manager)	
	menuMapa.Initialize(dataService.estaciones,APPSTATE.currntIdSitio)
	barraInfo.Initialize(dataService.timeToReconnect_Error)
	graficadora.Initialize(dataService,barraMenus)
	
	popUp.hide()
	panelDebug.visible = false
	
	DataRefresh()

func ClosePanels():
	CloseInfoMenu()
	CloseDebugPanel()

func CloseInfoMenu():
	if menuInfo.visible:
		menuInfo.visible = false
		APPSTATE.menuUIOptionIsOpened = false

func CloseDebugPanel():
	if panelDebug.visible:
		panelDebug.visible = false
		APPSTATE.menuUIOptionIsOpened = false

func DataRefresh():
	barraInfo.OnDataRefresh()
	menuPerfiles.DataRefresh(dataService.estaciones)
