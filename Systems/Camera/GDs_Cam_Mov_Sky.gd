class_name GDs_Cam_Mov_Sky extends Node

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
var mov_speed_boost : float
var mov_max_acceleration : float
var mov_velocity : Vector3
var mov_isMoving : bool
var mov_isPressingMove : bool
var mov_lastVelocity : Vector3
var mov_lastSpeed01:float = 0
var mov_limitSpeed : float

#Rotation
var rotHor_yaw : float = 0.0
var rotHor_yaw_direction : float = 1
var rotHor_cursorMovement : Vector2
var rotHor_isRotating : bool
var rotHor_velocity : Vector3
var MouseMotion : InputEvent

# Misc
var speed01 : float = 0
var curvIsRunning : bool
var canMoveCam : bool
var signalUpdateWasEmitted : bool
var tweenMovCamera : Tween
var curv01 : float
var curvEvaluateSpeed : float = .5
var curvPoint : float

const ROTHOR_THRESHOLD : float = 0.8

func Initialize(_camMng : GDs_Cam_Manager):
	camMng = _camMng
	cam = camMng.sky_cam
	pivot_cam = camMng.sky_pivot
	speed01 = 0
	
	UpdateCamConfig()

func _input(event):
	if event is InputEventMouseMotion:
		MouseMotion = event
	else:
		MouseMotion = null
	
func SetCamera():
	cam.current = true
	cam.global_position.y = camMng.sky_height
	cam.fov = camMng.sky_zoom_out
	cam.rotation.x = deg_to_rad(-80)
	mov_velocity = Vector3.ZERO
	currentFov = cam.fov
	curv01 = 0

func UpdateCamConfig():
	cam.global_position.y = camMng.sky_height
	cam.fov = camMng.sky_zoom_out
	
	#Movement
	mov_speed = camMng.sky_move
	mov_max_acceleration = camMng.sky_move
	mov_speed_boost = camMng.sky_boost
	
func _physics_process(delta):
	_Movement(delta)
	_Fov(delta)
	_Rotation(delta)
	
	#Check boundings map01
	camMng.CheckMapBoundings(pivot_cam)
	
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
		inputDir += pivot_cam.basis.z * axisLeftVert
		
	if axisLeftHor != 0:
		inputDir += pivot_cam.basis.x * -axisLeftHor
		
	mov_isPressingMove = inputDir.length() > 0
	inputDir = inputDir.normalized()

	if mov_isPressingMove:
		if curv01 < 1:
			#Calculate curve acc
			curv01 += curvEvaluateSpeed * _delta
			curv01 = clampf(curv01,0,1)
			curvPoint = camMng.curveMovement.sample(curv01)
		
		#Calculate velocity to move
		mov_velocity += inputDir * curvPoint * _delta
		@warning_ignore('incompatible_ternary')
		mov_limitSpeed = mov_speed * (mov_speed_boost if Input.is_action_pressed('3DMove_SpeedBoost') else 1)
		mov_velocity = mov_velocity.limit_length(mov_limitSpeed)
	elif not mov_isPressingMove and mov_velocity.length() > 0:
		#Calculate curve dec
		curv01 -= curvEvaluateSpeed * _delta
		curv01 = clampf(curv01,0,1)
		curvPoint = camMng.curveMovement.sample(curv01)
		
		#Calculate deceleration
		var targetLength : Vector3 = mov_velocity * curvPoint
		mov_velocity = lerp(mov_velocity, targetLength,curvPoint)
		if mov_velocity.length() < .001:
			mov_velocity = Vector3.ZERO
	
	#Apply movement
	#Save speed01 to send it to UI
	var fixSpeed : float =  inverse_lerp(0,mov_speed * mov_speed_boost,mov_velocity.length())
	var slowSpeed : float = lerpf(mov_lastSpeed01,fixSpeed, .2)
	speed01 = clampf(slowSpeed,0,1 if Input.is_action_pressed('3DMove_SpeedBoost') else .7)
	mov_lastSpeed01 = speed01
	
	#speed01 = inverse_lerp(0,mov_limitSpeed * mov_speed_boost,mov_velocity.length())
	if mov_velocity.length() > 0:
		#Apply
		mov_lastVelocity = mov_velocity
		mov_velocity = lerp(mov_lastVelocity, mov_velocity, 20)
		pivot_cam.global_position += mov_velocity

func _Rotation(_delta:float):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if MouseMotion != null:
			if MouseMotion.relative.x > 0:
				rotHor_yaw_direction = 1
			else:
				rotHor_yaw_direction = -1
			rotHor_cursorMovement += MouseMotion.relative * 2
			rotHor_cursorMovement.y = clampf(rotHor_cursorMovement.y, -(DisplayServer.screen_get_size()*1.0).y/2, (DisplayServer.screen_get_size()*1.0).y/2)
			rotHor_cursorMovement.x = clampf(rotHor_cursorMovement.x, -(DisplayServer.screen_get_size()*1.0).x/2, (DisplayServer.screen_get_size()*1.0).x/2)
			_rotHorPivot((rotHor_cursorMovement.x*2)/DisplayServer.screen_get_size().x * 10,1 ,_delta)
		else:
			_rotHorPivot((rotHor_cursorMovement.x*2)/DisplayServer.screen_get_size().x * 10,1, _delta)

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		rotHor_cursorMovement = Vector2.ZERO
		
	axisRightHor = Input.get_axis('3DMove_RotHor_-','3DMove_RotHor_+')
	if axisRightHor != 0:
		_rotHorPivot(axisRightHor, 5, _delta)
	
func _rotHorPivot(_dir:float, _factorSpeed : float, _delta:float):
	rotHor_yaw -= _dir * camMng.sky_camRot_speed * _factorSpeed  * _delta
	pivot_cam.rotation_degrees.y = rotHor_yaw

func _Fov(_delta : float):
	if Input.is_action_pressed("3DMove_Fov_+"):
		currentFov += 50 * _delta
		currentFov = clampf(currentFov, camMng.sky_zoom_in, camMng.sky_zoom_out)
		cam.fov = currentFov
	if Input.is_action_pressed("3DMove_Fov_-"):
		currentFov -= 50 * _delta
		currentFov = clampf(currentFov, camMng.sky_zoom_in, camMng.sky_zoom_out)
		cam.fov = currentFov

func _ResetVelocities():
	mov_velocity = Vector3.ZERO
