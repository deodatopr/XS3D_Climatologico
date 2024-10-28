extends Node

@export var sndDrone: AudioStreamPlayer

var tween:Tween

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
		if CAM.speed != 0:
			if not sndDrone.playing:
				sndDrone.play()
		else:
			sndDrone.stop()


func TweenDroneVolume(_volume:float):
	sndDrone.volume_db = _volume
