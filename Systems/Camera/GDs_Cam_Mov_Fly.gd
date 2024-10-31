class_name GDs_Cam_Mov_Fly extends Node

var camMng : GDs_Cam_Manager

var cam : Camera3D
var pivot : Node3D

var mov_deceleration : float = 100
var mov_velocity : Vector3 = Vector3.ZERO
var mov_axisMovement : Vector2
var mov_axisHeight : float
var mov_lastHeight : float
var mov_height_velocity : float
var mov_height_lerp : float

var rot_lastRotX : float
var rot_lastRotY : float
var rot_axisRotation : Vector2

var yaw : float = 0.0
var pitch : float = 0.0
var MouseMotion : InputEvent
var is_start_to_move : bool = false
var BoostTimeElapsed = 0
var CursorMovement : Vector2
var isInGround : bool = false
var isInTop : bool = false
var canPressDown : bool = true
var speed01 : float = 0
var lastSpeed01 : float = 0

func Initialize(_camMng : GDs_Cam_Manager):
	camMng = _camMng
	cam = camMng.fly_cam
	pivot = camMng.fly_pivot

func SetCamera():
	cam.current = true
	pivot.global_position.y = camMng.fly_height_start
	cam.position = Vector3.ZERO
	cam.rotation_degrees = Vector3(0, 180, 0)
	cam.fov = camMng.fly_fov
	
func UpdateCamConfig():
	cam.fov = camMng.fly_fov
	
func _input(event):
	if event is InputEventMouseMotion:
		MouseMotion = event
	else:
		MouseMotion = null

func _physics_process(delta:float):
	_movement(delta)
	_rotation(delta)
	
	#Check boundings map01
	camMng.CheckMapBoundings(pivot)
	
func _movement(_delta:float):
	_mov_height(_delta)
	_mov_movement(_delta)
	
func _mov_height(_delta : float):
	#Get input from  mouse/ controller
	mov_axisHeight = Input.get_axis("3DMove_Height_-","3DMove_Height_+")
	var heightDir : float = signf(mov_axisHeight)
	
	#Set limits
	var offsetLimits : float = 10
	var minHeightFromNavMesh : float = UTILITIES._get_point_on_map(pivot.position,cam,0).y
	var min : float = minHeightFromNavMesh + camMng.fly_height_min
	var max : float = minHeightFromNavMesh + camMng.fly_height_max
	var height01 : float = clampf(inverse_lerp(min,max,pivot.global_position.y),0,1)
	
	#Calculate new height
	mov_height_velocity = heightDir * 700 * _delta
	
	#Apply new height to an aux vector to evaluate distances
	var targetHeight : Vector3 = pivot.position
	targetHeight.y += mov_height_velocity
	
	#Check distance to ground
	var limitToDetectGround : float = .2
	var limitToDetectTop: float = .8
	isInGround = height01 <= limitToDetectGround
	isInTop = height01 >= limitToDetectTop
	if isInGround and heightDir < 0:
		mov_height_lerp = 1 - inverse_lerp(limitToDetectGround,0,height01)
	elif isInTop and heightDir > 0:
		mov_height_lerp = inverse_lerp(1,limitToDetectTop,height01)
	else:
		mov_height_lerp = 1
	
	mov_height_velocity *= mov_height_lerp
	
	#Apply
	var finalHeight : float = pivot.position.y
	finalHeight += mov_height_velocity
	finalHeight = clampf(finalHeight,min,max)
	
	var smoothness :float = 5
	pivot.position.y = lerpf(pivot.position.y, finalHeight, smoothness *_delta)
	mov_lastHeight = pivot.position.y

func _mov_movement(_delta : float):
	mov_axisMovement = Input.get_vector("3DMove_Right","3DMove_Left","3DMove_Backward","3DMove_Forward")
	var dir : Vector3 = pivot.basis * Vector3(mov_axisMovement.x,0,mov_axisMovement.y)

	var FinalSpeedTurbo : float = camMng.fly_turbo
	@warning_ignore('incompatible_ternary')
	FinalSpeedTurbo = camMng.fly_turbo if Input.is_action_pressed("3DMove_SpeedBoost") else 1
	
	if dir.length() > 0:
		mov_velocity += (dir * camMng.fly_speed * _delta) + mov_velocity.normalized() * (FinalSpeedTurbo)
		if mov_velocity.length() > mov_deceleration:	
			mov_velocity = mov_velocity.limit_length(mov_deceleration * FinalSpeedTurbo)
	
	else:
		if mov_velocity.length() > 0:
			mov_velocity -= mov_velocity.normalized() * mov_deceleration * _delta
			if mov_velocity.length() < 0.1:
				mov_velocity = Vector3.ZERO	
				BoostTimeElapsed = 0
	
	var fixSpeed : float =  inverse_lerp(0,camMng.fly_speed * camMng.fly_turbo,mov_velocity.length())
	var slowSpeed : float = lerpf(lastSpeed01,fixSpeed, .2)
	@warning_ignore('incompatible_ternary')
	speed01 = clampf(slowSpeed,0,1 if Input.is_action_pressed('3DMove_SpeedBoost') else .7)
	lastSpeed01 = speed01
	
	var targetPosition : Vector3 = pivot.global_position
	targetPosition += mov_velocity * _delta
	
	pivot.global_position = targetPosition

func _rotation(_delta:float):
	#Detect input controller
	rot_axisRotation = Input.get_vector("3DLook_Left",'3DLook_Right','3DLook_Down','3DLook_Up')
	var dir : Vector2 = rot_axisRotation
	
	#Detect input mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if MouseMotion != null:
			var fixedMouseMotion : Vector2 = MouseMotion.relative
			fixedMouseMotion.y = -fixedMouseMotion.y
			dir = fixedMouseMotion.normalized()

	CAM.isRotating = dir.length() > 0
	
	#Apply rot
	_rotation_Hor(dir.x,_delta)
	_rotation_vert(-dir.y,_delta)

	rot_lastRotX = pivot.rotation.x
	rot_lastRotY = pivot.rotation.y

func _rotation_Hor(_dir:float, _delta:float):
	yaw -= _dir * camMng.fly_rot_speed  * _delta
	var targetAngle : float = deg_to_rad(yaw)
	var smoothTarget : float = lerp_angle(rot_lastRotY,yaw,5 * _delta)
	pivot.rotation.y = smoothTarget

func _rotation_vert(_dir:float, _delta:float):
	pitch -= -_dir * camMng.fly_rot_speed  * _delta
	var targetAngle : float = deg_to_rad(pitch)
	var smoothTarget : float = lerp_angle(rot_lastRotX,pitch,5 * _delta)
	pivot.rotation.x = smoothTarget
