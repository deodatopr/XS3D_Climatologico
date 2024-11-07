extends Node

@export_group("Moving")
@export var sndFlying: AudioStreamPlayer
@export var flyingStaticVolume:float = -40
@export var flyingStaticPitch:float = 0.85
@export var flyingMovingVolume:float = -25
@export var flyingMovingPitch:float = 0.9
@export var flyingBoostVolume:float = -25
@export var flyingBoostPitch:float = 1

@export_group("Environment")
@export_subgroup("Wind")
@export var sndWind: AudioStreamPlayer
@export var windMinHeight:float
@export var windMaxHeight:float
@export_subgroup("Nature")
@export var sndNature: AudioStreamPlayer
@export var natureMinHeight:float
@export var natureMaxHeight:float

var isBoosting:=false
var tween:Tween
var prevCamHeight:=0

var windMidPoint:=0
var natureMidPoint:=0
func _ready():
	windMidPoint = ((windMaxHeight - windMinHeight)/2) + windMinHeight
	natureMidPoint = ((natureMaxHeight - natureMinHeight)/2) + natureMinHeight
	print_debug(natureMinHeight)
	print_debug(natureMidPoint)

func _process(_delta):
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
		#ROTATION SOUND
		elif CAM.isRotating:
			if not sndFlying.playing:
				MovingFade(sndFlying,0,0.7)
		#HEIGHT
		elif CAM.isHeightChanging:
			if not sndFlying.playing:
				MovingFade(sndFlying,flyingMovingVolume,flyingMovingPitch)
		#STATIC
		else:
			if sndFlying.playing:
				MovingFade(sndFlying,flyingStaticVolume,flyingStaticPitch,true)
#endregion
#region Environment
		if CAM.height > natureMinHeight and CAM.height < natureMidPoint:
			print_debug(inverse_lerp(natureMinHeight,natureMidPoint,CAM.height))
			sndWind.volume_db = linear_to_db(inverse_lerp(natureMinHeight,natureMidPoint,CAM.height))
		
		
#endregion

func MovingFade(_snd:AudioStreamPlayer,_vol:float,_pitch:float,_stop:=false):
	_snd.play()
	tween = create_tween()
	tween.tween_property(_snd,"volume_db",_vol,0.2)
	tween.parallel().tween_property(_snd,"pitch_scale",_pitch,0.2)
	if _stop:
		await tween.finished
		_snd.stop()
