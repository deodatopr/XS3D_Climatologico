class_name GDs_Cam_Mov_Aerial extends Node

var camMng : GDs_Cam_Manager
var cam : Camera3D
var pivot_cam : Node3D

var axisLeftVert : float
var axisLeftHor : float

var axisRightVert : float
var axisRightHor : float

#FOV
var currentFov : float

#Movement
var mov_speed : float
var mov_smooth_speed = 5
var mov_currentBoost : float
var mov_speed_boost : float
var mov_max_acceleration : float
var mov_velocity : Vector3
var mov_isMoving : bool
var mov_isPressingMove : bool

#Rotation
var rotHor_isRotating : bool
var rotHor_velocity : Vector3

# Misc
var speed01 : float
var curvIsRunning : bool
var canMoveCam : bool
var signalUpdateWasEmitted : bool
var tweenMovCamera : Tween
var tweenMshVfxRotCam : Tween
var curvAccl : Curve
var curvDecl : Curve

const ROTHOR_THRESHOLD : float = 0.8

func Initialize(_camMng : GDs_Cam_Manager):
	camMng = _camMng
	cam = camMng.cam
	pivot_cam = camMng.pivot_cam
	
	UpdateCamConfig()
	
func SetCamera():
	cam.position.y = camMng.aerial_height
	cam.fov = camMng.aerial_zoom_out
	cam.rotation.x = deg_to_rad(-80)
	currentFov = cam.fov

func UpdateCamConfig():
	cam.global_position.y = camMng.aerial_height
	cam.fov = camMng.aerial_zoom_out
	
	#Movement
	mov_speed = camMng.aerial_move * 10
	mov_max_acceleration = camMng.aerial_move
	mov_speed_boost = camMng.aerial_boost
	
	curvAccl = camMng.curveAccel
	curvDecl = camMng.curveDecel
	
func _physics_process(delta):
	_Movement(delta)
	_Fov(delta)
	_Rotation(delta)
	
	if (mov_isMoving or rotHor_isRotating) and not signalUpdateWasEmitted:
		SIGNALS.OnCameraUpdate.emit(true)
		signalUpdateWasEmitted = true
	elif (not mov_isMoving and not rotHor_isRotating and mov_velocity.length() == 0) and signalUpdateWasEmitted:
		SIGNALS.OnCameraUpdate.emit(false)
		signalUpdateWasEmitted = false

func _Movement(_delta: float):
	var inputDir = Vector3.ZERO
	
	axisLeftVert = Input.get_axis('3DMove_Backward', '3DMove_Forward')
	axisLeftHor = Input.get_axis('3DMove_Left', '3DMove_Right')
	
	if axisLeftVert != 0:
		inputDir += cam.global_basis.z * -axisLeftVert
		
	if axisLeftHor != 0:
		inputDir += cam.global_basis.x * axisLeftHor
		
	inputDir.y = 0
	inputDir = inputDir.normalized()

	var target_speed : float = mov_speed * (mov_speed_boost if Input.is_action_pressed('3DMove_SpeedBoost') else 1.0)
	var curvePoint : float = UTILITIES.GetCurvePoint(camMng.curveAccel, .5, _delta)
	target_speed *= curvePoint
	mov_velocity = lerp(mov_velocity, inputDir * target_speed, mov_smooth_speed * _delta)

	if inputDir == Vector3.ZERO and mov_velocity.length() > 0:
		var pointCurve : float = UTILITIES.GetCurvePoint(camMng.curveDecel, 1, _delta)
		var weight : float = pointCurve * (.1 * _delta)
		mov_velocity = lerp(mov_velocity, Vector3.ZERO,weight)
		if mov_velocity.length() < .001:
			mov_velocity = Vector3.ZERO
	
	#Apply
	speed01 = inverse_lerp(0,target_speed,mov_velocity.length())
	pivot_cam.global_position += mov_velocity * _delta

func _Rotation(_delta : float):
	axisRightHor = Input.get_axis('3DMove_RotHor_-',"3DMove_RotHor_+")
		
	if axisRightHor != 0:
		cam.global_rotate(Vector3.UP,-axisRightHor * camMng.aerial_camRot_speed * _delta)

func _Fov(_delta : float):
	if Input.is_action_pressed("3DMove_Fov_+"):
		currentFov += 50 * _delta
		currentFov = clampf(currentFov, camMng.aerial_zoom_in, camMng.aerial_zoom_out)
		cam.fov = currentFov
	if Input.is_action_pressed("3DMove_Fov_-"):
		currentFov -= 50 * _delta
		currentFov = clampf(currentFov, camMng.aerial_zoom_in, camMng.aerial_zoom_out)
		cam.fov = currentFov

func _ResetVelocities():
	mov_velocity = Vector3.ZERO
