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
			vistaAereo.show()
			vistaDron.hide()

func GlitchTransition():
	UTILITIES.TurnOnObject(glitch)
	tween = create_tween()
	tween.tween_method(ChangeGlitchIntensity,0.01,1,0.5)
	await tween.finished
	
	cortinilla.ShowCurtain()
	await cortinilla.OnCurtainCovered
	SIGNALS.OnCameraCanChangeMode
	cortinilla.HideCurtain()
	print_debug("asd")
	await cortinilla.OnCurtainFinished
	
	tween = create_tween()
	tween.tween_method(ChangeGlitchIntensity,1.0,0.01,0.5)
	await tween.finished
	
	UTILITIES.TurnOffObject(glitch)

func ChangeGlitchIntensity(intensity:float):
	glitch.material.set_shader_parameter("intensity", intensity)
