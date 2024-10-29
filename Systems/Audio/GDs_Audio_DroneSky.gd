extends Node

@export var sndDrone: AudioStreamPlayer
@export var sndDroneVolume: float = -5.0
@export var sndDronePitch: float = 2.0

var tween:Tween


func _process(delta):
	if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
		if Input.is_action_pressed("3DMove_Forward") or Input.is_action_pressed("3DMove_Backward") or Input.is_action_pressed("3DMove_Left") or Input.is_action_pressed("3DMove_Right"):
		#if CAM.speed != 0:
			if not sndDrone.playing:
				FadeIn(sndDrone)
				
		else:
			if sndDrone.playing:
				FadeOut(sndDrone)

func FadeIn(_audio:AudioStreamPlayer):
	_audio.play()
	tween = create_tween()
	tween.tween_property(_audio,"volume_db",sndDroneVolume,0.5)
	tween.parallel().tween_property(_audio,"pitch_scale",sndDronePitch,1.5)

func FadeOut(_audio:AudioStreamPlayer):
	tween = create_tween()
	tween.tween_property(_audio,"volume_db",-40,1)
	tween.parallel().tween_property(_audio,"pitch_scale",1,1)
	await tween.finished
	_audio.stop()

#TODO al cambiar de drone apagar el audio de fly
