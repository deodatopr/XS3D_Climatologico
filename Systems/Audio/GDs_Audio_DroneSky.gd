extends Node

@export var sndDrone: AudioStreamPlayer

var tween:Tween


func _process(delta):
	if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
		if CAM.speed != 0:
			if not sndDrone.playing:
				sndDrone.play()
				tween = create_tween()
				tween.tween_property(sndDrone,"volume_db",-15,0.3)
				tween.parallel().tween_property(sndDrone,"pitch_scale",2,0.3)
				
		else:
			if sndDrone.playing:
				sndDrone.stop()
				tween = create_tween()
				tween.tween_property(sndDrone,"volume_db",-80,0.3)
				tween.parallel().tween_property(sndDrone,"pitch_scale",1,0.3)

#TODO al cambiar de drone apagar el audio de fly
