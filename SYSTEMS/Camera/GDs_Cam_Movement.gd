class_name GDs_CamMovement extends Node

var cam : Node3D
var pivot_panning : Node3D

#Panning
var pan_acceleration : float
var pan_deceleration : float
var pan_max_acceleration : float

var pan_velocity : Vector3 = Vector3.ZERO

#Rotation
var speed_RotHor : float
var speed_RotVert : float
var allow_RotVert : bool

#Height
var height_acceleration
var height_max_acceleration
var height_deceleration

var height_velocity := 0.0
var height_dir := 0
var height_lastDir := 0

const THRESHOLD_ROT_MOUSE : float = .3

func Initialize(_cam : Camera3D, _pivot_panning : Node3D):
	cam = _cam
	pivot_panning = _pivot_panning
	
func SetModeConfig(_modeConfig : GDs_CR_Cam_ModeConfig):
	cam.global_position.y = _modeConfig.initialHeight
	cam.rotation_degrees.x = _modeConfig.initialInclination
	
	#Pannning
	pan_acceleration = _modeConfig.pan_acceleration
	pan_max_acceleration = _modeConfig.pan_max_acceleration
	pan_deceleration = _modeConfig.pan_deceleration
	
	#Rotation
	speed_RotHor = _modeConfig.speed_rotHor
	speed_RotVert = _modeConfig.speed_rotVert
	allow_RotVert = _modeConfig.allow_RotVert
	
	#Height
	height_acceleration = _modeConfig.height_acceleration
	height_max_acceleration = _modeConfig.height_max_acceleration
	height_deceleration = _modeConfig.height_deceleration

func _physics_process(delta):
	_Panning(delta)
	_Height(delta)
	_Rotation_Hor(delta)
	
	if allow_RotVert:
		_Rotation_Vert(delta)

func _Panning(_delta:float):
	var inputDir = Vector3.ZERO
	
	if Input.is_action_pressed("3DMove_Forward"):
		inputDir += pivot_panning.basis.z
	
	if Input.is_action_pressed("3DMove_Backward"):
		inputDir += -pivot_panning.basis.z
		
	if Input.is_action_pressed("3DMove_Right"):
		inputDir += -pivot_panning.basis.x
	
	if Input.is_action_pressed("3DMove_Left"):
		inputDir += pivot_panning.basis.x
	
	#Acceleration
	if inputDir.length() > 0:
		inputDir = inputDir.normalized()
		pan_velocity += inputDir * pan_acceleration * _delta
		
		#Limit pan_acceleration
		if pan_velocity.length() > pan_max_acceleration:
			pan_velocity = pan_velocity.normalized() * pan_max_acceleration
	else:
		#Deceleration
		if pan_velocity.length() > 0:
			pan_velocity -= pan_velocity.normalized() * pan_deceleration * _delta
			if pan_velocity.length() < 0.1:
				pan_velocity = Vector3.ZERO
	
	#Apply
	pivot_panning.global_position += pan_velocity * _delta


func _Rotation_Hor(_delta : float):
	#Mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouseDir = Input.get_last_mouse_velocity().normalized()
		var dirRotX = sign(mouseDir.x)
		
		if abs(mouseDir.x) > THRESHOLD_ROT_MOUSE:
			pivot_panning.rotate_y(-dirRotX * speed_RotHor * _delta)
			SIGNALS.OnCameraRotation.emit(dirRotX)
			
	#Control
	var joy_id = 0 
	if Input.is_joy_known(joy_id):
		var axisX = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_X)

		if abs(axisX) > 0.5:
			pivot_panning.rotate_y(-axisX * speed_RotHor * _delta)
			SIGNALS.OnCameraRotation.emit(axisX)
			
func CambiarInt(myint: int):
	myint = 5

func _Rotation_Vert(_delta : float):
	#Mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouseDir = Input.get_last_mouse_velocity().normalized()
		var dirRotY = sign(mouseDir.y)
		
		if abs(mouseDir.y) > THRESHOLD_ROT_MOUSE:
			cam.rotation_degrees.x += (-dirRotY * speed_RotVert * _delta)

	#Control
	var joy_id = 0 
	if Input.is_joy_known(joy_id):
		var axisY = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_Y)

		if abs(axisY) > 0.1:
			cam.rotation_degrees.x += (-axisY * speed_RotVert * _delta)


func _Height(_delta : float):
	#Input
	if Input.is_action_pressed("3DMove_Height_+") or Input.is_action_just_pressed("3DMove_Height_+"):
		height_dir = 1
		height_lastDir = 1
	elif Input.is_action_pressed("3DMove_Height_-") or Input.is_action_just_pressed("3DMove_Height_-"):
		height_dir = -1
		height_lastDir = -1
	else:
		height_dir = 0
	
	#Acceleration
	if height_dir != 0:
		height_velocity += height_dir * height_acceleration * _delta
		#Limit pan_acceleration
		if abs(height_velocity) > height_max_acceleration:
			height_velocity = sign(height_velocity) * height_max_acceleration
	else:
		#Deceleration
		if abs(height_velocity) > 0:
			height_velocity += (-height_lastDir) * height_deceleration * _delta

			if abs(height_velocity) < 0.01:
				height_velocity = 0.0
	
	#Apply pan_velocity
	cam.global_position.y += height_velocity * _delta
