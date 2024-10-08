class_name GDs_CamMovement extends Node

var cam : Camera3D
var pivot_panning : Node3D
var camFov : float

#Panning
var pan_acceleration : float
var pan_deceleration : float
var pan_max_acceleration : float
var pan_velocity : Vector3 = Vector3.ZERO

#Rotation
var rotHor_speed : float
var rotHor_velocity : float
var rotHor_deceleration : float

var rotHor_initDirCaptured : bool
var rotHor_initdir : Vector2
var rotHor_currentDir : Vector2

var rotVert_speed : float
var rotVert_allow : bool

#Height
var height_speed
var height_deceleration

var height_velocity : float
var height_dir : int
var height_validDir : int

var height_limit_Max : float
var height_limit_Min : float

const THRESHOLD_ROT_MOUSE : float = .3

func Initialize(_cam : Camera3D, _pivot_panning : Node3D):
	cam = _cam
	pivot_panning = _pivot_panning
	
func SetModeConfig(_modeConfig : GDs_CR_Cam_ModeConfig):
	#Cam
	cam.global_position.y = _modeConfig.initialHeight
	cam.rotation_degrees.x = _modeConfig.initialInclination
	cam.fov = _modeConfig.initialFOV
	
	#Pannning
	pan_acceleration = _modeConfig.pan_acceleration
	pan_max_acceleration = _modeConfig.pan_max_acceleration
	pan_deceleration = _modeConfig.pan_deceleration
	
	#Rotation
	rotHor_speed = _modeConfig.rotHor_speed
	rotHor_deceleration = _modeConfig.rotHor_deceleration
	rotVert_speed = _modeConfig.rotVert_speed
	rotVert_allow = _modeConfig.rotVert_allow
	
	#Height
	height_speed = _modeConfig.height_speed
	height_deceleration = _modeConfig.height_deceleration
	height_limit_Min = _modeConfig.height_limit_min
	height_limit_Max = _modeConfig.height_limit_max

func _physics_process(delta):
	_Panning(delta)
	_Height(delta)
	_Rotation_Hor(delta)
	
	if rotVert_allow:
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
		pan_velocity += inputDir * pan_acceleration * _delta
		
		#Limit pan_acceleration
		if pan_velocity.length() > pan_max_acceleration:
			pan_velocity = pan_velocity.limit_length(pan_max_acceleration)
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
		if not rotHor_initDirCaptured:
			rotHor_initdir = get_viewport().get_mouse_position()
			rotHor_initDirCaptured = true
			
		rotHor_currentDir = get_viewport().get_mouse_position()
		var mouseDir : Vector2 = rotHor_currentDir - rotHor_initdir
		
		#Avoid combine with rot Vert
		#if abs(mouseDir.y) > 0.4:
			#return
		
		var mouseDirRotX = sign(mouseDir.x)
		
		if mouseDirRotX != 0:
			rotHor_velocity = -mouseDirRotX * rotHor_speed * _delta
			pivot_panning.rotate_y(rotHor_velocity)
			SIGNALS.OnCameraRotation.emit(mouseDirRotX)
			
	if rotHor_initDirCaptured and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		rotHor_initDirCaptured = false
	
	#Control
	var joy_id = 0 
	if Input.is_joy_known(joy_id):
		var control_Dir = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_X)

		if abs(control_Dir) > 0.5:
			rotHor_velocity = -control_Dir * rotHor_speed * _delta
			pivot_panning.rotate_y(rotHor_velocity)
			SIGNALS.OnCameraRotation.emit(control_Dir)
	
	#Check if rot input is released
	var rotHorReleased : bool = false
	if Input.is_joy_known(joy_id):
		rotHorReleased =  abs(Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_X))< .4
	else:
		rotHorReleased = !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	#Deceleration
	var rotHor_velocity_abs = abs(rotHor_velocity)
	var dir = sign(rotHor_velocity)
	if rotHorReleased and rotHor_velocity_abs > 0:
		rotHor_velocity -= dir * rotHor_deceleration * _delta
		if rotHor_velocity_abs < 0.0001:
			rotHor_velocity = 0
		
		pivot_panning.rotate_y(rotHor_velocity)

func _Rotation_Vert(_delta : float):
	#Mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouseDir = Input.get_last_mouse_velocity().normalized()
		
		#Avoid combine with rot Hor
		if abs(mouseDir.x) > 0.4:
			return
			
		rotHor_velocity = 0
		var dirRotY = sign(mouseDir.y)
		
		if abs(mouseDir.y) > THRESHOLD_ROT_MOUSE:
			cam.rotation_degrees.x += (-dirRotY * rotVert_speed * _delta)

	#Control
	var joy_id = 0 
	if Input.is_joy_known(joy_id):
		var axisY = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_Y)

		if abs(axisY) > 0.1:
			cam.rotation_degrees.x += (-axisY * rotVert_speed * _delta)

func _Height(_delta : float):
	#Input
	if Input.is_action_pressed("3DMove_Height_+") or Input.is_action_just_pressed("3DMove_Height_+"):
		height_dir = 1
		height_validDir = 1
	elif Input.is_action_pressed("3DMove_Height_-") or Input.is_action_just_pressed("3DMove_Height_-"):
		height_dir = -1
		height_validDir = -1
	else:
		height_dir = 0
	
	#Movement
	if height_dir != 0:
			height_velocity = height_dir * height_speed * _delta
	else:
		#Deceleration
		if abs(height_velocity) > 0:
			height_velocity += (-height_validDir) * height_deceleration * _delta

			if abs(height_velocity) < 0.01:
				height_velocity = 0.0
	
	#Apply velocity
	var targetHeight = cam.global_position.y
	targetHeight += height_velocity * _delta
	targetHeight = clampf(targetHeight,height_limit_Min,height_limit_Max)
	cam.global_position.y = targetHeight
