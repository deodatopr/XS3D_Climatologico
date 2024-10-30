class_name GDs_Cam_Mov_Fly extends Node

var camMng : GDs_Cam_Manager

var cam : Camera3D
var pivot : Node3D

var mov_deceleration : float = 100
var mov_velocity : Vector3 = Vector3.ZERO

var rot_lastRoX : float
var rot_lastRoY : float
var rot_rotation : Vector2

var yaw : float = 0.0
var pitch : float = 0.0
var MouseMotion : InputEvent
var is_start_to_move : bool = false
var last_cam_rotation : Vector3
var last_pivot_rotation : Vector3
var return_cam_time_elpased : float = 0
var last_pitch : float = 0
var yaw_direction = 1
var BoostTimeElapsed = 0
var CursorMovement : Vector2
var isInGround : bool = false
var isInTop : bool = false
var canPressDown : bool = true
var speed01 : float = 0
var lastSpeed01 : float = 0

const RETURN_CAMERA_ADJUST : float = 0.1

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
	var inputDir = Vector3.ZERO

	if Input.is_action_pressed("3DMove_Forward"):
		inputDir += pivot.basis.z

	if Input.is_action_pressed("3DMove_Backward"):
		inputDir += -pivot.basis.z

	if Input.is_action_pressed("3DMove_Right"):
		inputDir += -pivot.basis.x

	if Input.is_action_pressed("3DMove_Left"):
		inputDir += pivot.basis.x
		
	if Input.is_action_pressed("3DMove_Height_+"):
		if !isInTop:
			inputDir += pivot.basis.y
			isInGround = false

	if Input.is_action_pressed("3DMove_Height_-"):
		if canPressDown:
			inputDir -= pivot.basis.y
			isInTop = false

	var FinalSpeedTurbo : float = camMng.fly_turbo
	@warning_ignore('incompatible_ternary')
	FinalSpeedTurbo = camMng.fly_turbo if Input.is_action_pressed("3DMove_SpeedBoost") else 1
	
	if inputDir.length() > 0:
		mov_velocity += (inputDir * camMng.fly_speed * _delta) + mov_velocity.normalized() * (FinalSpeedTurbo)
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
	
	var distanceToGround = targetPosition.distance_to(UTILITIES._get_point_on_map(targetPosition, cam,0))
	isInGround = distanceToGround < camMng.fly_height_min
	var pointInNavMesh := UTILITIES._get_point_on_map(cam.global_position, cam,0).y
	canPressDown = pivot.global_position.y > pointInNavMesh + camMng.fly_height_min - 4
	
	if isInGround:
		if targetPosition.y - UTILITIES._get_point_on_map(targetPosition, cam,0).y > .1:
			if inputDir != Vector3.UP:
				targetPosition.y = lerpf(targetPosition.y, pointInNavMesh + (Vector3.UP * (camMng.fly_height_min - 5)).y, .5)
		else:
			targetPosition.y = pointInNavMesh + (Vector3.UP * 50).y

	isInTop = targetPosition.y >= camMng.fly_height_max
	
	pivot.global_position = targetPosition


func _rotation(_delta:float):
	rot_rotation = Input.get_vector("3DLook_Left",'3DLook_Right','3DLook_Down','3DLook_Up')
	var dir : Vector2 = rot_rotation
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if MouseMotion != null:
			var fixedMouseMotion : Vector2 = MouseMotion.relative
			fixedMouseMotion.y = -fixedMouseMotion.y
			dir = fixedMouseMotion.normalized()

	_rotHorPivot(dir.x,_delta)
	_rotVertCam(-dir.y,_delta)
	
	CAM.isRotating = !is_equal_approx(pivot.rotation_degrees.x,rot_lastRoX) or !is_equal_approx(pivot.rotation_degrees.y,rot_lastRoY)

	rot_lastRoX = pivot.rotation.x
	rot_lastRoY = pivot.rotation.y

func _rotHorPivot(_dir:float, _delta:float):
	yaw -= _dir * camMng.fly_rot_speed  * _delta
	var startAngle : float = rot_lastRoY
	var targetAngle : float = deg_to_rad(yaw)
	var smoothTarget : float = lerp_angle(rot_lastRoY,yaw,5 * _delta)
	pivot.rotation.y = smoothTarget

func _rotVertCam(_dir:float, _delta:float):
	pitch -= -_dir * camMng.fly_rot_speed  * _delta
	var startAngle : float = rot_lastRoX
	var targetAngle : float = deg_to_rad(pitch)
	var smoothTarget : float = lerp_angle(rot_lastRoX,pitch,5 * _delta)
	pivot.rotation.x = smoothTarget
