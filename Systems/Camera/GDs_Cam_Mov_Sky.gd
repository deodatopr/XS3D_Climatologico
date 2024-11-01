class_name GDs_Cam_Mov_Sky extends Node

var camMng : GDs_Cam_Manager
var cam : Camera3D
var pivot : Node3D


#FOV
var fov_current : float
var fov_01 : float
var fov_lensDistIntensity : float

#Movement
var mov_axis : Vector2
var mov_speed01 : float = 0
var mov_curv01 : float
var mov_velocity : Vector3
var mov_isMoving : bool
var mov_isPressingMove : bool
var mov_lastVelocity : Vector3
var mov_lastSpeed01:float = 0
var mov_limitSpeed : float
var mov_isInsideBoundings : bool
var mov_lastBounding01 : float

#Rotation
var rot_axis : float
var rot_hor : float
var rot_cursorMovement : Vector2
var rot_velocity : Vector3
var rot_lastRotDir : float
var rot_lastMouseDir : float
var rot_lastRot : float
var rot_lastMousePos01 : float
var mouseMotion : InputEvent

# Misc
var signalUpdateWasEmitted : bool
var curvEvaluateSpeed : float = .5
var curvPoint : float

func Initialize(_camMng : GDs_Cam_Manager):
	camMng = _camMng
	cam = camMng.sky_cam
	pivot = camMng.sky_pivot
	mov_speed01 = 0
	
	UpdateCamConfig()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouseMotion = event
	else:
		mouseMotion = null
	
func SetCamera():
	cam.current = true
	cam.fov = camMng.sky_zoom_out	
	pivot.position.y = camMng.sky_height
	
	mov_velocity = Vector3.ZERO
	mov_curv01 = 0	
	rot_hor = pivot.rotation.y
	fov_current = cam.fov
	
	_SetLensDistorsion(fov_current)

func UpdateCamConfig():
	cam.global_position.y = camMng.sky_height
	cam.fov = camMng.sky_zoom_out
	
func _physics_process(delta):
	_Movement(delta)
	_Rotation(delta)
	_Fov(delta)
	
	#Check boundings map01
	mov_isInsideBoundings = camMng.CheckMapBoundings(pivot)

func _Movement(_delta: float):
	mov_axis = Input.get_vector('3DMove_Left','3DMove_Right','3DMove_Backward','3DMove_Forward')	
	var isPressingTurbo : bool = Input.is_action_pressed('3DMove_SpeedBoost') 
	var inputDir : Vector3 = pivot.global_basis * Vector3(-mov_axis.x,mov_axis.y,0).normalized()
	
	mov_isPressingMove = mov_axis.length() > 0

	if mov_isPressingMove:
		#Acceleration
		
		if mov_curv01 < 1:
			#Calculate curve acc
			mov_curv01 += curvEvaluateSpeed * _delta
			mov_curv01 = clampf(mov_curv01,0,1)
			curvPoint = camMng.curveMovement.sample(mov_curv01)
		
		#Calculate velocity to move
		mov_velocity += inputDir * camMng.sky_speed * curvPoint * _delta
		@warning_ignore('incompatible_ternary')
		mov_limitSpeed = camMng.sky_speed * (camMng.sky_turbo if isPressingTurbo else 1)
		mov_velocity = mov_velocity.limit_length(mov_limitSpeed)
	elif not mov_isPressingMove and mov_velocity.length() > 0:
		#Deceleration
		
		#Calculate curve dec
		mov_curv01 -= curvEvaluateSpeed * _delta
		mov_curv01 = clampf(mov_curv01,0,1)
		curvPoint = camMng.curveMovement.sample(mov_curv01)
		
		#Calculate deceleration
		var targetLength : Vector3 = mov_velocity * curvPoint
		mov_velocity = lerp(mov_velocity, targetLength,curvPoint)
		if mov_velocity.length() < .001:
			mov_velocity = Vector3.ZERO
			
	#Velocity decrease by boundings
	var decreaseSpeedByLimits : float = (1 - CAM.boundings01)
	var isDirTowardLimit : bool = signf(mov_lastBounding01 - decreaseSpeedByLimits) > 0
	
	#No decrease speed if dir is diferent toward limit (to escape easily)
	if not isDirTowardLimit:
		decreaseSpeedByLimits = 1

	mov_lastBounding01 = (1 - CAM.boundings01)
	mov_velocity = mov_velocity * decreaseSpeedByLimits
	
	#Save mov_speed01 to send it to UI
	var fixSpeed : float =  inverse_lerp(0,camMng.sky_speed * camMng.sky_turbo,mov_velocity.length())
	var slowSpeed : float = lerpf(mov_lastSpeed01,fixSpeed, 10 * _delta)
	mov_speed01 = clampf(slowSpeed,0, 1)
	mov_lastSpeed01 = mov_speed01
	
	#Apply movement
	if mov_velocity.length() > 0:
		mov_velocity.y = 0
		pivot.global_position += mov_velocity
		mov_lastVelocity = mov_velocity

func _Rotation(_delta:float):
	#Detect input controller
	rot_axis = Input.get_axis('3DLook_Left','3DLook_Right')
	var dir : float = signf(rot_axis)
	
	#Detect input mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if mouseMotion != null:
			var rotDir : float = signf(mouseMotion.relative.x)
			rotDir = 1 if rotDir >= 0 else -1
			dir = rotDir


	CAM.isRotating = dir != 0
	dir = lerp(rot_lastRotDir,dir,5 *_delta)
	
	#Apply rot
	_rotation_hor(dir,_delta)

	rot_lastRotDir = dir
	rot_lastRot = pivot.rotation.y
	
func _rotation_hor(_dir:float, _delta:float):
	rot_hor -= _dir * camMng.sky_rot_speed  * _delta
	var targetAngle : float = rot_hor
	var smoothTarget : float = lerp_angle(rot_lastRot,targetAngle,15 * _delta)
	pivot.rotation.y = smoothTarget

func _Fov(_delta : float):
	if Input.is_action_pressed("3DLook_Fov_+"):
		fov_current += 50 * _delta
		fov_current = clampf(fov_current, camMng.sky_zoom_in, camMng.sky_zoom_out)
		cam.fov = fov_current
		_SetLensDistorsion(fov_current)
	if Input.is_action_pressed("3DLook_Fov_-"):
		fov_current -= 50 * _delta
		fov_current = clampf(fov_current, camMng.sky_zoom_in, camMng.sky_zoom_out)
		cam.fov = fov_current
		_SetLensDistorsion(fov_current)

func _SetLensDistorsion(_currentFov : float):
	fov_01 = inverse_lerp(camMng.sky_zoom_in,camMng.sky_zoom_out,_currentFov)
	fov_lensDistIntensity = lerpf(1.5,1,fov_01)
	camMng.matFishEye.set_shader_parameter("lensDistortion",fov_lensDistIntensity)
