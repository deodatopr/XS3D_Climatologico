extends Node

@export_group("Moving")
@export var sndMoving: AudioStreamPlayer
@export var sndMovingVolume:float = 3.0
@export var sndMovingPitch: float = 1.0
@export var sndMovingTurboPitch: float = 2.0
@export_group("Camera FOV")
@export var sndCameraFOV: AudioStreamPlayer
@export var sndCameraFOVVolume: float = 10.0
@export var sndCameraFOVPitch: float = 0.7
@export_group("CameraRot")
@export var sndCameraRot: AudioStreamPlayer
@export var sndCameraRotVolume: float = 7
@export var sndCameraRotPitch: float = 0.5
@export_group("Wind")
@export var sndWind: AudioStreamPlayer
@export var sndWindVolume: float = -5
@export var sndWindStaticPitch: float = 0.8
@export var sndWindMovingPitch: float = 1.2
@export var sndWindTurboPitch: float = 2


var tweenMoving:Tween
var tweenCamFOV:Tween
var tweenWind:Tween
var sndCameraVol:float
var isBoosting = false

func _ready():
	SIGNALS.OnCameraChangedMode.connect(OnChangeDrone)

func _process(_delta):
	if APPSTATE.menuUIOptionIsOpened:
		MovingFadeOut()
		WindFadeOut()
		sndCameraRot.stop()
		CameraFadeOut()
	elif APPSTATE.camMode == ENUMS.Cam_Mode.sky and not APPSTATE.menuUIOptionIsOpened:
#region Moving
		if Input.is_action_pressed("3DMove_Forward") or Input.is_action_pressed("3DMove_Backward") or Input.is_action_pressed("3DMove_Left") or Input.is_action_pressed("3DMove_Right"):
			if Input.is_action_pressed("3DMove_SpeedBoost") and not isBoosting:
				isBoosting = true
				MovingFadeInTurbo()
				WindFadeIn(sndWindTurboPitch)
			elif not Input.is_action_pressed("3DMove_SpeedBoost") and isBoosting: 
				isBoosting = false
				MovingFadeIn()
				WindFadeIn(sndWindMovingPitch)
			else:
				if not sndMoving.playing:
					isBoosting = false
					MovingFadeIn()
					WindFadeIn(sndWindMovingPitch)
		else:
			if sndMoving.playing:
				MovingFadeOut()
				WindFadeOut()
		
#endregion
#region CameraFOV
		if Input.is_action_pressed("3DMove_Height_-") and Input.is_action_pressed("3DMove_Height_+"):
			if sndCameraFOV.playing:
				CameraFadeOut()
		elif Input.is_action_pressed("3DMove_Height_-") and CAM.fov > 30:
			if not sndCameraFOV.playing:
				CameraFadeIn()
		elif Input.is_action_pressed("3DMove_Height_+") and CAM.fov < 100:
			if not sndCameraFOV.playing:
				CameraFadeIn()
		else:
			if sndCameraFOV.playing:
				CameraFadeOut()
#endregion
#region Camera Rotation
		sndCameraRot.pitch_scale = sndCameraRotPitch
		sndCameraRot.volume_db = sndCameraRotVolume
		if CAM.isRotating:
			sndCameraRot.play()
		else:
			sndCameraRot.stop()
#endregion
		sndWind.volume_db = sndWindVolume

 
func MovingFadeIn():
	sndMoving.play()
	if tweenMoving: tweenMoving.kill()
	tweenMoving = create_tween()
	tweenMoving.tween_property(sndMoving,"volume_db",sndMovingVolume,0.2)
	tweenMoving.parallel().tween_property(sndMoving,"pitch_scale",sndMovingPitch,0.2)
 
func MovingFadeInTurbo():
	sndMoving.play()
	if tweenMoving: tweenMoving.kill()
	tweenMoving = create_tween()
	tweenMoving.tween_property(sndMoving,"volume_db",sndMovingVolume,0.2)
	tweenMoving.parallel().tween_property(sndMoving,"pitch_scale",sndMovingTurboPitch,0.2)

func MovingFadeOut():
	if tweenMoving: tweenMoving.kill()
	tweenMoving = create_tween()
	tweenMoving.tween_property(sndMoving,"volume_db",-10,0.5)
	tweenMoving.parallel().tween_property(sndMoving,"pitch_scale",1,0.5)
	await tweenMoving.finished
	sndMoving.stop()

#region Camera FOV
func CameraFadeIn():
	sndCameraFOV.play()
	tweenCamFOV = create_tween()
	tweenCamFOV.tween_property(sndCameraFOV,"volume_db",sndCameraFOVVolume,0.1)
	tweenCamFOV.parallel().tween_property(sndCameraFOV,"pitch_scale",sndCameraFOVPitch,0.1)

func CameraFadeOut():
	tweenCamFOV = create_tween()
	tweenCamFOV.tween_property(sndCameraFOV,"volume_db",-10,0.1)
	tweenCamFOV.parallel().tween_property(sndCameraFOV,"pitch_scale",sndCameraFOVPitch - 0.4,0.1)
	await tweenCamFOV.finished
	sndCameraFOV.stop()
#endregion

func WindFadeIn(_pitch:float):
	sndWind.play()
	tweenWind = create_tween()
	tweenWind.parallel().tween_property(sndWind,"pitch_scale",_pitch,0.1)

func WindFadeOut():
	tweenWind = create_tween()
	tweenWind.parallel().tween_property(sndWind,"pitch_scale",sndWindStaticPitch,0.1)


func OnChangeDrone(_mode:int):
	if _mode == ENUMS.Cam_Mode.sky:
		sndWind.play()	
	if _mode == ENUMS.Cam_Mode.fly:
		sndWind.stop()
		
