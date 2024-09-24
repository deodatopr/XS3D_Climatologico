extends Node
class_name GDs_Splash

@export_category("SPLASH")
@export var DebugSkip : bool
@export var splashes : Array[Control] = []
@export var durationEverySplash : float = 0.8
@export var speedFadeAnim : float = .5


@export var bgk : Control
@export var timer : Timer

var tween : Tween

signal OnFinishSplash

func Show():
	bgk.show()
	
	#Iniciar alpha de splashes en 0 
	for splashImg in splashes:
		splashImg.show()
		var initColor = splashImg.self_modulate
		initColor.a = 0
		splashImg.self_modulate = initColor
	
	#Animacion de fade in / fade out de cada splash
	for splashImg in splashes:
		#Fade in
		var targetColor_show = splashImg.self_modulate
		targetColor_show.a = 1
		tween = create_tween()
		tween.tween_property(splashImg, "self_modulate", targetColor_show, speedFadeAnim)
		await tween.finished
		
		#Tiempo que permanece visible con alpha 1 la imagen actual
		timer.start(durationEverySplash)
		tween.kill()
		
		await timer.timeout
		
		#Fade out
		var targetColor_hide = splashImg.self_modulate
		targetColor_hide.a = 0
		tween = create_tween()
		tween.tween_property(splashImg, "self_modulate", targetColor_hide, speedFadeAnim)
		
		await tween.finished
		splashImg.hide()
		
	tween.kill()
	
	#Fade out background
	var targetColor = bgk.self_modulate
	targetColor.a = 0
	tween = create_tween()
	tween.tween_property(bgk, "self_modulate", targetColor, speedFadeAnim)
	await tween.finished
	
	#Termina splash
	bgk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bgk.hide()
	
	OnFinishSplash.emit()
