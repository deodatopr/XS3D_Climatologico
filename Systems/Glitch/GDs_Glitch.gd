extends Node

@export_subgroup("Vista Drones")
@export var vistaSky:Control
@export var vistaFly:GDs_VistaFree
@export_subgroup("PPE")
@export var glitch:Control
@export var cortinilla:GDs_LocalCurtain

var isFirstRun : bool = true
var tween:Tween

func _ready():
	#TODO: Quitar esto del ready y usar el Initialize en orquestador
	Initialize()

func Initialize():
	SIGNALS.OnCameraRequestChangeMode.connect(ChangeDrone)
	ChangeDrone(APPSTATE.camMode)

func ChangeDrone(_modoToChange : int):
	if not isFirstRun:
		GlitchTransition()
	else:
		isFirstRun = false
	
	match  _modoToChange:
		ENUMS.Cam_Mode.sky:
			vistaSky.show()
			vistaFly.hide()
		ENUMS.Cam_Mode.fly:
			vistaSky.hide()
			vistaFly.show()

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
