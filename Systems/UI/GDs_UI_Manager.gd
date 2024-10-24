extends Control

@export var cortinilla:GDs_LocalCurtain
@export_group("Vista Drones")
@export var vistaDron:Control
@export var vistaAereo:Control
@export_group("PPE")
@export var glitch:Control

var tween:Tween

func _ready():
	SIGNALS.OnCameraRequestChangeMode.connect(ChangeDrone)

func ChangeDrone(_modoToChange : int):
	match  _modoToChange:
		0:
			GlitchTransition()
			vistaDron.show()
			vistaAereo.hide()
		1:
			GlitchTransition()
			vistaDron.hide()
			vistaAereo.show()

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
