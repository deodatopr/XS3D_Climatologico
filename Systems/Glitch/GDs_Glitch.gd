extends Node
@export_group("Sonidos")
@export var sndGlitch:AudioStreamPlayer
@export var sndGlitchLimit:AudioStreamPlayer
@export_group("Vista Drones")
@export var vistaSky:Control
@export var vistaFly:GDs_VistaFree
@export_group("")
@export var glitch:Control
@export var cortinilla:GDs_LocalCurtain
@export var mensaje:CanvasLayer


var isFirstRun : bool = true
var tween:Tween
var isInTransition := false

func _ready():
	#TODO: Quitar esto del ready y usar el Initialize en orquestador
	Initialize()

func Initialize():
	SIGNALS.OnCameraRequestChangeMode.connect(ChangeDrone)
	ChangeDrone(APPSTATE.camMode)

func _process(delta):
	if CAM.boundings01 == 0: 
		if glitch.visible and not isInTransition:
			UTILITIES.TurnOffObject(glitch)
			sndGlitchLimit.stop()
			mensaje.hide()
		return
	
	mensaje.show()
	UTILITIES.TurnOnObject(glitch)
	ChangeGlitchIntensity(CAM.boundings01 * .3)
	sndGlitchLimit.volume_db = -20 + (CAM.boundings01 * 20)
	if not sndGlitchLimit.playing:
		sndGlitchLimit.play()

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
	isInTransition = true
	UTILITIES.TurnOnObject(glitch)
	sndGlitch.pitch_scale = randf_range(0.7,1.4)
	sndGlitch.play()
	
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
	
	isInTransition = false
	

func ChangeGlitchIntensity(intensity:float):
	glitch.material.set_shader_parameter("intensity", intensity)
