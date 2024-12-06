class_name GDs_Cam_Mov_Fly extends Node3D

var camMng : GDs_Cam_Manager

var cam : Camera3D
var pivot : Node3D

var mov_speed_ms : float 
var mov_axisMovement : Vector2
var mov_sampleCurve : float
var mov_deceleration : float = 100
var mov_velocity : Vector3
var mov_lastVelocity : Vector3
var mov_lastBounding01 : float
var mov_speedForUI : float
var mov_lastSpeedForUI : float

var mov_height_speed : float
var mov_height_axis : float
var mov_height_last : float
var mov_height_velocity : float
var mov_height_lerp : float
var mov_height_isInGround : bool
var mov_height_isInTop : bool
var mov_height_speedForUI : float
var mov_height_lastSpeedForUI : float

var rot_hor : float
var rot_vert : float
var rot_lastRotX : float
var rot_lastRotY : float
var rot_lastDir : Vector2
var rot_axisRotation : Vector2

var currentTurbo : float
var mouseMotion : InputEvent
var cursorMovement : Vector2
var curvValue : float

func Initialize(_camMng : GDs_Cam_Manager):
	camMng = _camMng
	cam = camMng.fly_cam
	pivot = camMng.fly_pivot
	rot_hor = pivot.rotation.y
	rot_vert = pivot.rotation.x

func SetCamera():
	cam.current = true
	pivot.global_position.y =clampf(pivot.global_position.y,camMng.fly_height_min,camMng.fly_height_max) 
	cam.fov = camMng.fly_fov
	mov_height_speed = camMng.fly_height_speed * 100
	mov_speed_ms = (camMng.fly_speed * 1000) / 3600
	mov_speed_ms *=.01
	
func UpdateValuesInRuntime():
	cam.fov = camMng.fly_fov
	mov_height_speed = camMng.fly_height_speed * 100
	mov_speed_ms = (camMng.fly_speed * 1000) /3600
	mov_speed_ms *=.01
	
func _input(event):
	if event is InputEventMouseMotion:
		mouseMotion = event

func _physics_process(delta:float):
	if APPSTATE.menuUIOptionIsOpened:
		return
	
	@warning_ignore('incompatible_ternary')
	currentTurbo = camMng.fly_turbo if Input.is_action_pressed("3DMove_SpeedBoost") else 1
	
	_movement(delta)
	_rotation(delta)
	
	#Check boundings map01
	camMng.CheckMapBoundings(pivot)
	
func _movement(_delta:float):
	_mov_height(_delta)
	_mov_movement(_delta)
	
func _mov_height(_delta : float):
	#Get input from  mouse/ controller
	mov_height_axis = Input.get_axis("3DMove_Height_-","3DMove_Height_+")
	var heightDir : float = signf(mov_height_axis)
	
	#Set limits
	var minHeightFromNavMesh : float = camMng.GetPointOnMap(pivot.position).y
	@warning_ignore('shadowed_global_identifier')
	var min : float = minHeightFromNavMesh + camMng.fly_height_min
	@warning_ignore('shadowed_global_identifier')
	var max : float = minHeightFromNavMesh + camMng.fly_height_max
	var height01 : float = clampf(inverse_lerp(min,max,pivot.global_position.y),0,1)
	
	#Calculate new height
	mov_height_velocity = heightDir * mov_height_speed * currentTurbo * _delta
	
	#Apply new height to an aux vector to evaluate distances
	var targetHeight : Vector3 = pivot.position
	targetHeight.y += mov_height_velocity
	
	#Check distance to ground
	var limitHeight01ToDetectGround : float = .2
	var limitHeight01ToDetectTop: float = .8
	mov_height_isInGround = height01 <= limitHeight01ToDetectGround
	mov_height_isInTop = height01 >= limitHeight01ToDetectTop
	if mov_height_isInGround and heightDir < 0:
		mov_height_lerp = 1 - inverse_lerp(limitHeight01ToDetectGround,0,height01)
	elif mov_height_isInTop and heightDir > 0:
		mov_height_lerp = inverse_lerp(1,limitHeight01ToDetectTop,height01)
	else:
		mov_height_lerp = 1
	
	mov_height_velocity *= mov_height_lerp

	#Apply
	var finalHeight : float = pivot.position.y
	finalHeight += mov_height_velocity
	finalHeight = clampf(finalHeight,min,max)
	
	var smoothness :float = 5
	pivot.position.y = lerpf(pivot.position.y, finalHeight, smoothness *_delta)
	mov_height_last = pivot.position.y
	
	#Speed to send to UI (km/hr)
	var targetSpeed : float = camMng.fly_height_speed * 10.0 * currentTurbo * absf(heightDir)
	mov_height_speedForUI = lerpf(mov_height_lastSpeedForUI,targetSpeed, 10 * _delta)
	mov_height_lastSpeedForUI = mov_height_speedForUI

func _mov_movement(_delta : float):
	mov_axisMovement = Input.get_vector("3DMove_Left","3DMove_Right","3DMove_Forward","3DMove_Backward")
	var dir : Vector3 = (pivot.basis * Vector3(mov_axisMovement.x,0,mov_axisMovement.y).normalized())
	dir.y = 0
	
	if dir.length() > 0:
		#Acceleration
		if mov_sampleCurve < 1:
			#Curve acceleration
			mov_sampleCurve += _delta
			mov_sampleCurve = clampf(mov_sampleCurve,0,1)
			curvValue = camMng.curveMovement.sample(mov_sampleCurve)
			
		#Calculate velocity to move
		mov_velocity += dir * mov_speed_ms * curvValue * _delta
		var mov_limitSpeed : float = mov_speed_ms * currentTurbo
		mov_velocity = mov_velocity.limit_length(mov_limitSpeed)
	elif dir.length() == 0 and mov_velocity.length() > 0:
		#Deceleration		
		#Calculate curve dec
		mov_sampleCurve -= _delta
		mov_sampleCurve = clampf(mov_sampleCurve,0,1)
		curvValue = camMng.curveMovement.sample(mov_sampleCurve)
		
		#Calculate deceleration
		var targetLength : Vector3 = mov_velocity * curvValue
		mov_velocity = lerp(mov_velocity, targetLength,curvValue)
		if mov_velocity.length() < .001:
			mov_velocity = Vector3.ZERO
	
	#Limits
	#Velocity decrease by boundings
	var decreaseSpeedByLimits : float = (1 - CAM.boundings01)
	var isDirTowardLimit : bool = signf(mov_lastBounding01 - decreaseSpeedByLimits) > 0
	
	#No decrease speed if dir is diferent toward limit (to escape easily)
	if not isDirTowardLimit:
		decreaseSpeedByLimits = 1

	mov_lastBounding01 = (1 - CAM.boundings01)
	mov_velocity = mov_velocity * decreaseSpeedByLimits
	
	#Apply move
	if mov_velocity.length() > 0:
		pivot.global_position += mov_velocity

	#Speed to send to UI (km/hr) 
	var fixedDir : float = 1.0 if dir.length() > 0 else 0.0
	mov_speedForUI = lerpf(mov_lastSpeedForUI,camMng.fly_speed * currentTurbo * fixedDir, 10 * _delta)
	mov_lastSpeedForUI = mov_speedForUI
	
func _rotation(_delta:float):
	#Detect input controller
	rot_axisRotation = Input.get_vector("3DLook_Left",'3DLook_Right','3DLook_Up','3DLook_Down')
	var dir : Vector2 = rot_axisRotation
	
	#Detect input mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if mouseMotion != null:

			dir = mouseMotion.relative.normalized()

	CAM.isRotating = dir.length() > 0
	
	dir = lerp(rot_lastDir,dir,5 *_delta)
	
	var turbo : float = camMng.fly_rot_turbo if Input.is_action_pressed('3DMove_SpeedBoost') else 1
	
	#Apply rot
	_rotation_hor(dir.x,turbo,_delta)
	_rotation_vert(-dir.y,turbo,_delta)

	rot_lastRotX = pivot.rotation.x
	rot_lastRotY = pivot.rotation.y
	rot_lastDir = dir

func _rotation_hor(_dir:float, _turbo : float, _delta:float):
	rot_hor -= _dir * camMng.fly_rot_speed_hor * _turbo * _delta
	var targetAngle : float = rot_hor
	var smoothness : float = 15.0
	var smoothTarget : float = lerp_angle(rot_lastRotY,targetAngle,smoothness * _delta)
	pivot.rotation.y = smoothTarget

func _rotation_vert(_dir:float, _turbo : float, _delta:float):
	var toEvaluateAngle : float = rot_vert
	toEvaluateAngle -= -_dir * camMng.fly_rot_speed_vert * _turbo * _delta 
	toEvaluateAngle = clampf(toEvaluateAngle,deg_to_rad(-camMng.fly_rot_clamp),deg_to_rad(camMng.fly_rot_clamp))
	rot_vert = toEvaluateAngle
	var targetAngle : float = rot_vert
	var smoothness : float = 20.0
	var smoothTarget : float = lerp_angle(rot_lastRotX,targetAngle,smoothness * _delta)
	
	pivot.rotation.x = smoothTarget
