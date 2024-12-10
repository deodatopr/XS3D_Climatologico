extends Node

@export_group("Moving")
@export var sndFlying: AudioStreamPlayer
@export var sndCameraRot: AudioStreamPlayer
@export_custom(PROPERTY_HINT_NONE, "suffix:dB") var flyingStaticVolume:float = -40
@export var flyingStaticPitch:float = 0.85
@export_custom(PROPERTY_HINT_NONE, "suffix:dB") var flyingMovingVolume:float = -25
@export var flyingMovingPitch:float = 0.9
@export_custom(PROPERTY_HINT_NONE, "suffix:dB") var flyingBoostVolume:float = -25
@export var flyingBoostPitch:float = 1

@export_group("Environment")
@export_subgroup("Wind")
@export var sndWind: AudioStreamPlayer
@export var windMaxVolume:float = 24
@export var windMinHeight:float
@export var windMaxHeight:float
@export_subgroup("Nature")
@export var sndNature: AudioStreamPlayer
@export var natureMaxVolume: float = 24
@export var natureMinHeight:float
@export var natureMaxHeight:float
@export var streamNature:AudioStream
@export var streamRain:AudioStream
@export var rainVolume:float = -5.0
@export_subgroup("Audios 3D")
@export var audios3D : Array[Node3D] = []

var isBoosting:=false
var tween:Tween
var prevCamHeight:=0

var windMidPoint : float = 0.0
var natureMidPoint : float = 0.0
var originalNatureMinHeight: float = 0.0
var originalNatureVolume: float = 0.0


func _ready():
	if audios3D.size() == 0:
		print("NOTA: FALTA AGREGAR LOS AUDIOS 3D EN ESTE SCRIPT [ ",name," ]")
	
	originalNatureVolume = sndNature.volume_db
	originalNatureMinHeight = natureMinHeight
	
	windMidPoint = ((windMaxHeight - windMinHeight)/2) + windMinHeight
	natureMidPoint = ((natureMaxHeight - natureMinHeight)/2) + natureMinHeight
	
	SIGNALS.OnRefresh.connect(_OnRefresh)
	SIGNALS.OnCameraChangedMode.connect(_OnCameraChange)

func _OnCameraChange(_mode : int):
	if audios3D.size() == 0:
		return
	
	if _mode == ENUMS.Cam_Mode.sky:
		for audio in audios3D:
			UTILITIES.TurnOffObject(audio)
	else:
		for audio in audios3D:
			UTILITIES.TurnOnObject(audio)

func _process(_delta):
	if APPSTATE.menuUIOptionIsOpened:
		MovingFade(sndFlying,flyingStaticVolume,flyingStaticPitch,true)
		MovingFade(sndCameraRot,flyingStaticVolume,flyingStaticPitch,true)
	
	if APPSTATE.camMode == ENUMS.Cam_Mode.fly:
#region Drone
		#MOVING SOUND
		if Input.is_action_pressed("3DMove_Forward") or Input.is_action_pressed("3DMove_Backward") or Input.is_action_pressed("3DMove_Left") or Input.is_action_pressed("3DMove_Right"):
			if Input.is_action_pressed("3DMove_SpeedBoost") and not isBoosting:
				isBoosting = true
				MovingFade(sndFlying,flyingBoostVolume,flyingBoostPitch)
			elif not Input.is_action_pressed("3DMove_SpeedBoost") and isBoosting: 
				isBoosting = false
				MovingFade(sndFlying,flyingMovingVolume,flyingMovingPitch)
			else:
				if not sndFlying.playing:
					isBoosting = false
					MovingFade(sndFlying,flyingMovingVolume,flyingMovingPitch)
		#HEIGHT
		elif CAM.isHeightChanging:
			if not sndFlying.playing:
				MovingFade(sndFlying,flyingMovingVolume,flyingMovingPitch)
		#STATIC
		else:
			if sndFlying.playing:
				MovingFade(sndFlying,flyingStaticVolume,flyingStaticPitch,true)
			
		
		if CAM.isRotating:
			if not sndCameraRot.playing:
				MovingFade(sndCameraRot,0,0.7)
		else:
			if sndCameraRot.playing:
				MovingFade(sndCameraRot,flyingStaticVolume,flyingStaticPitch,true)
#endregion
#region Environment
		if CAM.height > natureMinHeight and CAM.height < natureMidPoint:
			if not sndNature.playing: sndNature.play()
			var volume01 = inverse_lerp(natureMinHeight,natureMidPoint,CAM.height)
			var volumedb = lerp(-10.0,natureMaxVolume,volume01)
			sndNature.volume_db = volumedb
		if CAM.height >= natureMidPoint and CAM.height < natureMaxHeight:
			if not sndNature.playing: sndNature.play()
			var volume01 = inverse_lerp(natureMidPoint,natureMaxHeight,CAM.height)
			var volumedb = lerp(natureMaxVolume,-10.0,volume01)
			sndNature.volume_db = volumedb
		if CAM.height > windMinHeight:
			if not sndWind.playing: sndWind.play()
			var volume01 = inverse_lerp(windMinHeight,windMaxHeight,CAM.height)
			var volumedb = lerp(-10.0,windMaxVolume,volume01)
			if volumedb >= 24: volumedb =24
			sndWind.volume_db = volumedb
		else:
			sndWind.volume_db = -10
		
#endregion
	else:
		sndFlying.stop()
		sndNature.stop()
		sndWind.stop()

func MovingFade(_snd:AudioStreamPlayer,_vol:float,_pitch:float,_stop:=false):
	_snd.play()
	tween = create_tween()
	tween.tween_property(_snd,"volume_db",_vol,0.2)
	tween.parallel().tween_property(_snd,"pitch_scale",_pitch,0.2)
	if _stop:
		await tween.finished
		_snd.stop()

func _OnRefresh():
	if APPSTATE.currntSitio.lloviendo:
		natureMinHeight = 0
		natureMidPoint = 100
		sndNature.stream = streamRain
		sndNature.volume_db = rainVolume
	else:
		natureMinHeight = originalNatureMinHeight
		natureMidPoint = ((natureMaxHeight - natureMinHeight)/2) + natureMinHeight
		sndNature.stream = streamNature
		sndNature.volume_db = originalNatureVolume
		
