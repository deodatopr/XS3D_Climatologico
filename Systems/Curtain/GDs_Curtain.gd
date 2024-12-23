class_name GDs_Curtain extends Node

@export var curtain : Control
@export var imgCurtain : Control
@export var inputBlocker : Control
@export var container : Control

signal OnCurtainCovered
signal OnCurtainFinished

var isCovered : bool
var originalColor : Color
var tween : Tween
var speedFade : float = 0.5

func _ready() -> void:
	originalColor = imgCurtain.self_modulate
	
	var tmpColor = originalColor
	tmpColor.a = 0
	imgCurtain.self_modulate = tmpColor
	
	curtain.process_mode = Node.PROCESS_MODE_DISABLED
	curtain.hide()
	inputBlocker.hide()
	container.hide()
	
func Show():
	if isCovered:
		return
	
	inputBlocker.show()
	curtain.show()
	
	curtain.process_mode = Node.PROCESS_MODE_INHERIT
	tween = create_tween()
	
	#Fade in
	var colorTarget = originalColor
	tween.tween_property(imgCurtain, "self_modulate", colorTarget, speedFade)
	
	await tween.finished
	
	#Prender animacion loading
	isCovered = true
	container.show()
	OnCurtainCovered.emit()

func Hide():
	container.hide()
	tween = create_tween()
	
	#Fade out
	var colorTarget = originalColor
	colorTarget.a = 0
	tween.tween_property(imgCurtain, "self_modulate", colorTarget, speedFade)
	
	inputBlocker.hide()
	await tween.finished
	isCovered = false
	curtain.process_mode = Node.PROCESS_MODE_DISABLED
	curtain.hide()
	
	OnCurtainFinished.emit()
