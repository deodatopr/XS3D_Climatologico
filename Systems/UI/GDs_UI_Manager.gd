extends Control

@export_group("Refs externas")
@export var dataService:GDs_DataService_Manager
@export_subgroup("Vista Drones")
@export var vistaSky:Control
@export var vistaFree:GDs_VistaFree
@export_subgroup("PPE")
@export var glitch:Control
@export_subgroup("Refs Minimap")
@export var cam_manager:GDs_Cam_Manager
@export var worldMark:Node3D
@export var map:Node3D
@export_group("Refs internas")
@export var cortinilla:GDs_LocalCurtain
@export var menuPerfiles:GDs_MenuPerfiles

var isFirstRun : bool = true
var tween:Tween

func _ready():
	#TODO: Quitar esto del ready y usar el Initialize en orquestador
	Initialize()

func Initialize():
	SIGNALS.OnCameraRequestChangeMode.connect(ChangeDrone)
	dataService.OnDataRefresh.connect(DataRefresh)
	
	vistaFree.cam_manager = cam_manager
	vistaFree.worldMark = worldMark
	vistaFree.map = map
	vistaFree.Initialize()
	ChangeDrone(APPSTATE.camMode)

func DataRefresh():
	menuPerfiles.DataRefresh(dataService.estaciones)

func ChangeDrone(_modoToChange : int):
	if not isFirstRun:
		GlitchTransition()
	else:
		isFirstRun = false
	
	match  _modoToChange:
		ENUMS.Cam_Mode.sky:
			vistaSky.show()
			vistaFree.hide()
		ENUMS.Cam_Mode.fly:
			vistaSky.hide()
			vistaFree.show()

func GlitchTransition():
	UTILITIES.TurnOnObject(glitch)
	tween = create_tween()
	tween.tween_method(ChangeGlitchIntensity,0.5,1,0.1)
	await tween.finished
	
	UTILITIES.TurnOnObject(cortinilla)
	cortinilla.ShowCurtain()
	await cortinilla.OnCurtainCovered
	SIGNALS.OnCameraCanChangeMode.emit()
	cortinilla.HideCurtain()
	await cortinilla.OnCurtainFinished
	
	tween = create_tween()
	tween.tween_method(ChangeGlitchIntensity,1.0,0.5,0.1)
	await tween.finished
	
	UTILITIES.TurnOffObject(glitch)
	UTILITIES.TurnOffObject(cortinilla)

func ChangeGlitchIntensity(intensity:float):
	glitch.material.set_shader_parameter("intensity", intensity)
