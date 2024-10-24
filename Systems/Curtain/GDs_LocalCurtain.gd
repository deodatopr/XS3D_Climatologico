class_name GDs_LocalCurtain
extends Control

@export var speedFade:=1.0
@export var colorTarget := Color.BLACK
@export var colorTransparent := Color.BLACK

var tween:Tween
signal OnCurtainCovered
signal OnCurtainFinished

func ShowCurtain():
	tween = create_tween()
	tween.tween_property(self, "self_modulate", colorTarget, speedFade)
	await tween.finished
	OnCurtainCovered.emit()

func HideCurtain():
	tween = create_tween()
	tween.tween_property(self, "self_modulate", colorTransparent, speedFade)
	await tween.finished
	OnCurtainFinished.emit()
