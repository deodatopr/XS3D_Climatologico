extends Node

@export_group("Components")
@export var cam : Node3D
@export var pivot : Node3D

@export_group("Camera Controllers")
@export var speedAccDecc : float = 200
@export var speed : float = 200
@export_range(1, 4) var speedTurbo : float = 2
@export var rotHorSpeed : float = 1.5
@export var rotVertSpeed : float = 5
@export_range(0, 90) var rotVertMax : float = 90.0
@export_range(-90, 0) var rotVertMin : float = -90.0
@export var rotVertReturn : float = 1
@export var rotCurveAcc : Curve

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

const RETURN_CAMERA_ADJUST : float = 0.1

func Initialize(_cam : Camera3D, _pivot : Node3D):
	cam = _cam
	pivot = _pivot
	
func _ready():
	mov_deceleration = speedAccDecc
	
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
		
		if mov_velocity.length() > speedAccDecc:
			mov_velocity = mov_velocity.limit_length(speedAccDecc + (FinalSpeedTurbo * 10))
		print(FinalSpeedTurbo)
	else:
		if mov_velocity.length() > 0:
			mov_velocity -= mov_velocity.normalized() * mov_deceleration * _delta
			if mov_velocity.length() < 0.1:
				mov_velocity = Vector3.ZERO
	
	print(mov_velocity)
	var targetPosition : Vector3 = pivot.global_position
	targetPosition += mov_velocity * _delta

	pivot.global_position = targetPosition

func _rotation(_delta:float):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		if not is_start_to_move:
			return_cam_time_elpased = 0
			is_start_to_move = true
			pitch = last_pitch
			
		if MouseMotion != null:
			yaw -= MouseMotion.relative.x * rotHorSpeed  * _delta
			pitch -= MouseMotion.relative.y * rotVertSpeed  * _delta
			last_pitch = pitch

			pitch = clampf(pitch, rotVertMin, rotVertMax)

			pivot.rotation_degrees.y = yaw
			cam.rotation_degrees.x = pitch

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if abs(cam.rotation_degrees.x) > .1:
			cam.rotation_degrees.x = lerpf(cam.rotation_degrees.x, 0, return_cam_time_elpased / (rotVertReturn / RETURN_CAMERA_ADJUST))
			return_cam_time_elpased += _delta
			last_pitch = cam.rotation_degrees.x
			is_start_to_move = false
		else:
			cam.rotation_degrees.x = 0
			pitch = 0
			last_pitch = 0
		
	if Input.is_action_pressed("3DMove_Right"):
		pass
		#yaw -= MouseMotion.relative.x * rotHorSpeed * _delta
		#pitch -= MouseMotion.relative.y * rotVertSpeed * _delta
