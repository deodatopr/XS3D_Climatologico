extends Node

@export var sndMoving: AudioStreamPlayer
@export var sndMovingVolume: float = -5.0
@export var sndMovingPitch: float = 2.0
@export var sndWind: AudioStreamPlayer
@export var sndCameraFOV: AudioStreamPlayer
@export var sndCameraRot: AudioStreamPlayer


var tween:Tween
var sndCameraVol:float

func _ready():
	SIGNALS.OnCameraChangedMode.connect(OnChangeDrone)
	sndCameraVol = sndCameraFOV.volume_db


func _process(_delta):
	if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
		if Input.is_action_pressed("3DMove_Forward") or Input.is_action_pressed("3DMove_Backward") or Input.is_action_pressed("3DMove_Left") or Input.is_action_pressed("3DMove_Right"):
		#if CAM.speed != 0:
			if not sndMoving.playing:
				FadeIn(sndMoving, sndMovingVolume,sndMovingPitch)
			sndWind.pitch_scale = 1.5
			
		else:
			if sndMoving.playing:
				FadeOut(sndMoving,-40,1)
			sndWind.pitch_scale = 1
	
#region CameraFOV
		if Input.is_action_pressed("3DMove_Height_-") and Input.is_action_pressed("3DMove_Height_+"):
			if sndCameraFOV.playing:
				CameraFadeOut()
		elif Input.is_action_pressed("3DMove_Height_+") and CAM.fov > 30:
			if not sndCameraFOV.playing:
				CameraFadeIn()
		elif Input.is_action_pressed("3DMove_Height_-") and CAM.fov < 100:
			if not sndCameraFOV.playing:
				CameraFadeIn()
		else:
			if sndCameraFOV.playing:
				CameraFadeOut()
#endregion
		if CAM.isRotating:
			sndCameraRot.play()
		else:
			sndCameraRot.stop()

 
func FadeIn(_audio:AudioStreamPlayer,targetVol:float, targetPitch:float):
	_audio.play()
	tween = create_tween()
	tween.tween_property(_audio,"volume_db",targetVol,0.5)
	tween.parallel().tween_property(_audio,"pitch_scale",targetPitch,1.5)

func FadeOut(_audio:AudioStreamPlayer,targetVol:float, targetPitch:float):
	tween = create_tween()
	tween.tween_property(_audio,"volume_db",targetVol,1)
	tween.parallel().tween_property(_audio,"pitch_scale",targetPitch,1)
	await tween.finished
	_audio.stop()

func CameraFadeIn():
	sndCameraFOV.play()
	tween = create_tween()
	tween.tween_property(sndCameraFOV,"volume_db",10,0.1)
	tween.parallel().tween_property(sndCameraFOV,"pitch_scale",0.7,0.1)

func CameraFadeOut():
	tween = create_tween()
	tween.tween_property(sndCameraFOV,"volume_db",-10,0.1)
	tween.parallel().tween_property(sndCameraFOV,"pitch_scale",0.5,0.1)
	await tween.finished
	sndCameraFOV.stop()
	pass


func OnChangeDrone(_mode:int):
	if _mode == ENUMS.Cam_Mode.sky:
		sndWind.play()	
	if _mode == ENUMS.Cam_Mode.fly:
		sndWind.stop()
		
