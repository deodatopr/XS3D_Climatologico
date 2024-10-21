extends Node

@export_group("Components")
@export var cam : Node3D
@export var pivot : Node3D

@export_group("Camera Controllers")
@export var speedAccDecel : float = 200
@export var speed : float = 200
@export_range(1, 4) var speedTurbo : float = 2
@export var rotHorSpeed : float = 2.5
@export var rotVertSpeed : float = 5
@export_range(0, 90) var rotVertMax : float = 90.0
@export_range(-90, 0) var rotVertMin : float = -90.0
@export var rotVertReturn : float = 1
@export var rotCurveAcc : Curve
@export var rotCurveDecel : Curve

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

const RETURN_CAMERA_ADJUST : float = 0.1

func Initialize(_cam : Camera3D, _pivot : Node3D):
	cam = _cam
	pivot = _pivot
	
func _ready():
	mov_deceleration = speedAccDecel
	
func _unhandled_input(event):
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

	if inputDir.length() > 0:
		var FinalSpeedTurbo = speedTurbo
		FinalSpeedTurbo = speedTurbo if Input.is_action_pressed("3DMove_SpeedBoost") else 0.0
		mov_velocity += (-inputDir * speed * _delta) + mov_velocity.normalized() * (FinalSpeedTurbo * 10)
		
		if mov_velocity.length() > speedAccDecel:
			
			mov_velocity = mov_velocity.limit_length(speedAccDecel + (FinalSpeedTurbo * 10))
	else:
		if mov_velocity.length() > 0:
			mov_velocity -= mov_velocity.normalized() * mov_deceleration * _delta
			if mov_velocity.length() < 0.1:
				mov_velocity = Vector3.ZERO
	
	var targetPosition : Vector3 = pivot.global_position
	targetPosition += mov_velocity * _delta

	pivot.global_position = targetPosition

func _rotation(_delta:float):
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		if MouseMotion != null:
			if MouseMotion.relative.x > 0:
				yaw_direction = 1
			else:
				yaw_direction = -1
			_rotHorPivot(MouseMotion.relative.x, _delta)
			_rotVertCam(MouseMotion.relative.y, _delta)

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_pressed("3DLook_Up") or Input.is_action_pressed("3DLook_Down"):
		_rotVertCam(-Input.get_axis("3DLook_Down", '3DLook_Up') * 10, _delta)
	else:
		_rotVertReturn(_delta)
		
	if Input.is_action_pressed("3DLook_Right") or Input.is_action_pressed("3DLook_Left"):
		yaw_direction = -Input.get_axis("3DLook_Right", '3DLook_Left')
		_rotHorPivot(yaw_direction * 10, _delta)
	elif not (Input.is_action_pressed("3DLook_Right") or Input.is_action_pressed("3DLook_Left")) and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= ((rotHorSpeed * (yaw_direction * 10)) * UTILITIES.GetCurvePoint(rotCurveDecel, 1.2, _delta, true)) * _delta
		pivot.rotation_degrees.y = yaw

func _rotHorPivot(dir:float, _delta:float):
	yaw -= dir * (rotHorSpeed * UTILITIES.GetCurvePoint(rotCurveAcc, 1.2, _delta, false)) * _delta
	pivot.rotation_degrees.y = yaw
	
func _rotVertCam(dir:float, _delta:float):
	if not is_start_to_move:
		return_cam_time_elpased = 0
		is_start_to_move = true
		pitch = last_pitch
		
	pitch -= dir * rotVertSpeed  * _delta
	last_pitch = pitch
	pitch = clampf(pitch, rotVertMin, rotVertMax)
	cam.rotation_degrees.x = pitch
		
func _rotVertReturn(_delta:float):
	if abs(cam.rotation_degrees.x) > .1:
		cam.rotation_degrees.x = lerpf(cam.rotation_degrees.x, 0, return_cam_time_elpased / (rotVertReturn / RETURN_CAMERA_ADJUST))
		return_cam_time_elpased += _delta
		last_pitch = cam.rotation_degrees.x
		is_start_to_move = false
	else:
		cam.rotation_degrees.x = 0
		pitch = 0
		last_pitch = 0
