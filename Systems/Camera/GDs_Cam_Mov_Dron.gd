class_name GDs_Cam_Mov_Dron extends Node

var camMng : GDs_Cam_Manager

var cam : Camera3D
var pivot : Node3D

var mov_deceleration : float
var mov_velocity : Vector3 = Vector3.ZERO

var yaw : float = 0.0
var pitch : float = 0.0
var MouseMotion : InputEvent
var is_start_to_move : bool = false
var last_cam_rotation : Vector3
var last_pivot_rotation : Vector3
var return_cam_time_elpased : float = 0
var last_pitch : float = 0
var yaw_direction = 1
var BoostTimeElapsed = -1.5
var CursorMovement : Vector2
var speed01 : float

const RETURN_CAMERA_ADJUST : float = 0.1

func Initialize(_camMng : GDs_Cam_Manager):
	camMng = _camMng
	cam = camMng.cam
	pivot = camMng.pivot_cam
	mov_deceleration = camMng.dron_speed_accel_decel
	
func SetCamera():
	pivot.global_position.y = camMng.dron_initialHeight
	cam.global_position = pivot.global_position
	cam.fov = camMng.dron_fov
	
func UpdateCamConfig():
	cam.fov = camMng.dron_fov
	
func _input(event):
	if event is InputEventMouseMotion:
		MouseMotion = event
	else:
		MouseMotion = null

func _physics_process(delta:float):
	_movement(delta)
	_rotation(delta)

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
		
	if Input.is_action_pressed("3DMove_Up"):
		inputDir += pivot.basis.y

	if Input.is_action_pressed("3DMove_Down"):
		inputDir -= pivot.basis.y

	var FinalSpeedTurbo : float = camMng.dron_boost
	FinalSpeedTurbo = camMng.dron_boost if Input.is_action_pressed("3DMove_SpeedBoost") else 0.0

	if inputDir.length() > 0:
		mov_velocity += (inputDir * camMng.dron_speed * _delta) + mov_velocity.normalized() * (FinalSpeedTurbo * 10)
		if mov_velocity.length() > camMng.dron_speed_accel_decel:
			mov_velocity = lerp(mov_velocity.limit_length(camMng.dron_speed_accel_decel), mov_velocity.limit_length(camMng.dron_speed_accel_decel + (FinalSpeedTurbo * 10)), 0)#clampf(BoostTimeElapsed, -1.5, .1))
			if FinalSpeedTurbo != 0 and BoostTimeElapsed <= .1:
				BoostTimeElapsed += _delta
			if FinalSpeedTurbo == 0 and BoostTimeElapsed > -1.5:
				BoostTimeElapsed -= _delta
		
	else:
		if mov_velocity.length() > 0:
			mov_velocity -= mov_velocity.normalized() * mov_deceleration * _delta
			if mov_velocity.length() < 0.1:
				mov_velocity = Vector3.ZERO
				BoostTimeElapsed = -1.5
	
	speed01 = inverse_lerp(0,camMng.dron_speed + (FinalSpeedTurbo * 10),mov_velocity.length())
	var targetPosition : Vector3 = pivot.global_position
	targetPosition += mov_velocity * _delta
	
	if targetPosition.distance_to(UTILITIES._get_point_on_map(targetPosition, cam,0)) < camMng.minDistGround:
		if targetPosition.y - UTILITIES._get_point_on_map(targetPosition, cam,0).y > .1:
			targetPosition.y = lerpf(targetPosition.y, UTILITIES._get_point_on_map(cam.global_position, cam,0).y + (Vector3.UP * (camMng.minDistGround - 5)).y, .5)
		else:
			targetPosition.y = UTILITIES._get_point_on_map(cam.global_position, cam,0).y + (Vector3.UP * 50).y

	pivot.global_position = targetPosition

func _rotation(_delta:float):
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if MouseMotion != null:
			if MouseMotion.relative.x > 0:
				yaw_direction = 1
			else:
				yaw_direction = -1
			CursorMovement += MouseMotion.relative * 2
			CursorMovement.y = clampf(CursorMovement.y, -(DisplayServer.screen_get_size()*1.0).y/2, (DisplayServer.screen_get_size()*1.0).y/2)
			CursorMovement.x = clampf(CursorMovement.x, -(DisplayServer.screen_get_size()*1.0).x/2, (DisplayServer.screen_get_size()*1.0).x/2)
			_rotHorPivot((CursorMovement.x*2)/DisplayServer.screen_get_size().x * 10, _delta)
			_rotVertCam((CursorMovement.y*2)/DisplayServer.screen_get_size().y * 10, _delta)
		else:
			_rotHorPivot((CursorMovement.x*2)/DisplayServer.screen_get_size().x * 10, _delta)
			_rotVertCam((CursorMovement.y*2)/DisplayServer.screen_get_size().y * 10, _delta)

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		CursorMovement = Vector2.ZERO
		
	if Input.is_action_pressed("3DLook_Up") or Input.is_action_pressed("3DLook_Down"):
		_rotVertCam(-Input.get_axis("3DLook_Down", '3DLook_Up') * 10, _delta)
	elif not (Input.is_action_pressed("3DLook_Up") or Input.is_action_pressed("3DLook_Down")) and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_rotVertReturn(_delta)
		
	if Input.is_action_pressed("3DLook_Right") or Input.is_action_pressed("3DLook_Left"):
		yaw_direction = -Input.get_axis("3DLook_Right", '3DLook_Left')
		_rotHorPivot(yaw_direction * 10, _delta)
	elif not (Input.is_action_pressed("3DLook_Right") or Input.is_action_pressed("3DLook_Left")) and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		yaw -= ((camMng.dron_rot_hor_speed * (yaw_direction * 10)) * UTILITIES.GetCurvePoint(camMng.curveDecel, 1.2, _delta, true)) * _delta
		pivot.rotation_degrees.y = yaw

func _rotHorPivot(dir:float, _delta:float):
	yaw -= dir * (camMng.dron_rot_hor_speed * UTILITIES.GetCurvePoint(camMng.curveAccel, 1.2, _delta, false)) * _delta
	pivot.rotation_degrees.y = yaw

func _rotVertCam(dir:float, _delta:float):
	if not is_start_to_move:
		return_cam_time_elpased = 0
		is_start_to_move = true
		pitch = last_pitch
		
	pitch -= dir * camMng.dron_rot_vert_speed  * _delta
	last_pitch = pitch
	pitch = clampf(pitch, camMng.dron_vert_min, camMng.dron_vert_max)
	cam.rotation_degrees.x = pitch
		
func _rotVertReturn(_delta:float):
	if abs(cam.rotation_degrees.x) > .1:
		cam.rotation_degrees.x = lerpf(cam.rotation_degrees.x, 0, return_cam_time_elpased / (camMng.dron_vert_return / RETURN_CAMERA_ADJUST))
		return_cam_time_elpased += _delta
		last_pitch = cam.rotation_degrees.x
		is_start_to_move = false
	else:
		cam.rotation_degrees.x = 0
		pitch = 0
		last_pitch = 0
