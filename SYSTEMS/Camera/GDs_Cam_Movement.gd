class_name GDs_CamMovement extends Node

var cam : Camera3D
var pivot_panning : Node3D
var camFov : float

#Panning
var pan_acceleration : float
var pan_deceleration : float
var pan_max_acceleration : float
var pan_velocity : Vector3 = Vector3.ZERO
var pan_bounding_X_min : float
var pan_bounding_X_max : float
var pan_bounding_Z_min : float
var pan_bounding_Z_max : float


#Rotation
var rot_initialRotX : float

var rotHor_allow : bool
var rotHor_speed : float
var rotHor_velocity : float
var rotHor_deceleration : float

var rotHor_initDirCaptured : bool
var rotHor_initdir : Vector2
var rotHor_currentDir : Vector2
var rotHor_isRotating : bool

var rotVert_speed : float
var rotVert_allow : bool

var rotVert_initDirCaptured : bool
var rotVert_initdir : Vector2
var rotVert_currentDir : Vector2
var rotVert_maxRotFromInitial : float
var rotVert_isRotating : bool

#Height
var height_speed
var height_deceleration

var height_velocity : float
var height_dir : int
var height_validDir : int

var height_limit_Max : float
var height_limit_Min : float

#FOV
var fov_changeByHeight : bool
var fov_min : float
var fov_max : float

const ROTVERT_THRESHOLD : float = 0.8
const ROTHOR_THRESHOLD : float = 0.8

func Initialize(_cam : Camera3D, _pivot_panning : Node3D):
	cam = _cam
	pivot_panning = _pivot_panning
	
func SetModeConfig(_modeConfig : GDs_CR_Cam_ModeConfig):
	#Cam
	rot_initialRotX = _modeConfig.initialInclination
	cam.rotation_degrees.x = rot_initialRotX
	
	var initHeight : float = clampf(_modeConfig.initialHeight, _modeConfig.height_limit_min, _modeConfig.height_limit_max)
	cam.global_position.y = initHeight
	
	if _modeConfig.fov_changeByHeight:
		var height01 = inverse_lerp(height_limit_Min,height_limit_Max,cam.global_position.y)
		var targetFov = lerpf(fov_min,fov_max,height01)
		cam.fov = targetFov
	else:
		cam.fov = _modeConfig.fov_static
		
	OnUpdateCRCam(_modeConfig)

	
func OnUpdateCRCam(_modeConfig : GDs_CR_Cam_ModeConfig):
	#Reset velocities
	pan_velocity = Vector3.ZERO
	rotHor_velocity = 0
	height_velocity = 0
	
	#Pannning
	pan_acceleration = _modeConfig.pan_acceleration
	pan_max_acceleration = _modeConfig.pan_max_acceleration
	pan_deceleration = _modeConfig.pan_deceleration
	pan_bounding_X_min = _modeConfig.boundings_X_min
	pan_bounding_X_max = _modeConfig.boundings_X_max
	pan_bounding_Z_min = _modeConfig.boundings_Z_min
	pan_bounding_Z_max = _modeConfig.boundings_Z_max
	
	#Rotation
	rotHor_allow = _modeConfig.rotHor_allow
	rotHor_speed = _modeConfig.rotHor_speed
	rotHor_deceleration = _modeConfig.rotHor_deceleration
	rotVert_speed = _modeConfig.rotVert_speed
	rotVert_allow = _modeConfig.rotVert_allow
	rotVert_maxRotFromInitial = _modeConfig.rotVert_maxRotFromInitial
	
	#Height
	height_speed = _modeConfig.height_speed
	height_deceleration = _modeConfig.height_deceleration
	height_limit_Min = _modeConfig.height_limit_min
	height_limit_Max = _modeConfig.height_limit_max
	
	#FOV
	fov_changeByHeight = _modeConfig.fov_changeByHeight
	fov_min = _modeConfig.fov_height_min
	fov_max = _modeConfig.fov_height_max

func _physics_process(delta):
	_Panning(delta)
	_Height(delta)
	_FOV()
	
	if rotVert_allow and not rotHor_isRotating:
		_Rotation_Vert(delta)
		
	if rotHor_allow and not rotVert_isRotating:
		_Rotation_Hor(delta)

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
	var targetPosition : Vector3 = pivot_panning.global_position
	targetPosition += pan_velocity * _delta
	targetPosition.x = clampf(targetPosition.x, pan_bounding_X_min, pan_bounding_X_max)
	targetPosition.z = clampf(targetPosition.z, pan_bounding_Z_min, pan_bounding_Z_max)
	
	var isInBoundX = abs(pivot_panning.global_position.x -  pan_bounding_X_min) < 0.01 or abs(pivot_panning.global_position.x -  pan_bounding_X_max) < 0.01
	var isInBoundZ = abs(pivot_panning.global_position.z -  pan_bounding_Z_min) < 0.01 or abs(pivot_panning.global_position.z -  pan_bounding_Z_max) < 0.01
	
	if isInBoundX || isInBoundZ:
		pan_velocity = Vector3.ZERO
	
	pivot_panning.global_position = targetPosition

func _Rotation_Vert(_delta : float):	
#region [ MOUSE ]
	#Mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not rotVert_initDirCaptured:
			rotVert_initdir = get_viewport().get_mouse_position()
			rotVert_initDirCaptured = true
			
		rotVert_currentDir = get_viewport().get_mouse_position()
		
		var mouseDir : Vector2 = (rotVert_currentDir - rotVert_initdir).normalized()
		var mouseIsMovingVert = abs(mouseDir.dot(Vector2.UP)) >= ROTVERT_THRESHOLD
		if mouseIsMovingVert:
			rotVert_isRotating = true
			rotHor_velocity = 0
			var targetRotX : float = cam.rotation_degrees.x
			targetRotX +=(-sign(mouseDir.y) * rotVert_speed * _delta)
			targetRotX = clampf(targetRotX, rot_initialRotX - rotVert_maxRotFromInitial, rot_initialRotX + rotVert_maxRotFromInitial)
			cam.rotation_degrees.x = targetRotX
			
	if rotVert_initDirCaptured and not  Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		@warning_ignore('standalone_expression')
		rotVert_initDirCaptured
#endregion

#region [ CONTROL ]
	#Control
	var joy_id = 0 
	if Input.is_joy_known(joy_id):
		var axisY = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_Y)
		print(axisY)
		if abs(axisY) >= ROTVERT_THRESHOLD:
			rotVert_isRotating = true
			var targetRotX : float = cam.rotation_degrees.x
			targetRotX += (-sign(axisY) * rotVert_speed * _delta)
			targetRotX = clampf(targetRotX, rot_initialRotX - rotVert_maxRotFromInitial, rot_initialRotX + rotVert_maxRotFromInitial)
			cam.rotation_degrees.x = targetRotX 
#endregion

#region [ BACK TO ORIGINAL ROT]
	if rotVert_isRotating and !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and  Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_Y) < .3:
		var current_rotation = cam.rotation_degrees.x
		var difference = rot_initialRotX - current_rotation
		if abs(difference) > 0.2:
			cam.rotation_degrees.x += sign(difference) * 20 * _delta
		else:
			rotVert_isRotating = false
			cam.rotation_degrees.x = rot_initialRotX
#endregion

func _Rotation_Hor(_delta : float):
#region [ MOUSE ]
	#Mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#Get initial mouse pos
		if not rotHor_initDirCaptured:
			rotHor_initdir = get_viewport().get_mouse_position()
			rotHor_initDirCaptured = true
		
		#Get current mouse pos
		rotHor_currentDir = get_viewport().get_mouse_position()
		
		#Get dir
		var mouseDir : Vector2 = (rotHor_currentDir - rotHor_initdir).normalized()
		var mouseIsMovingHor = abs(mouseDir.dot(Vector2.RIGHT)) >= ROTHOR_THRESHOLD
		if mouseIsMovingHor:
			var mouseDirRotX = sign(mouseDir.x)
			rotHor_velocity = -mouseDirRotX * rotHor_speed * _delta
			pivot_panning.rotate_y(rotHor_velocity)
			SIGNALS.OnCameraRotation.emit(mouseDirRotX)
			
	if rotHor_initDirCaptured and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		rotHor_initDirCaptured = false
#endregion
	
#region [ CONTROL ]
	#Control
	var joy_id = 0 
	if Input.is_joy_known(joy_id):
		var control_Dir = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_X)

		if abs(control_Dir) > ROTHOR_THRESHOLD:
			rotHor_velocity = -control_Dir * rotHor_speed * _delta
			pivot_panning.rotate_y(rotHor_velocity)
			SIGNALS.OnCameraRotation.emit(control_Dir)
#endregion
	
#region [ DECELERATION ]
	#Deceleration
	var rotHorReleased : bool = false
	if Input.is_joy_known(joy_id):
		rotHorReleased =  abs(Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_X))< .4
	else:
		rotHorReleased = !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	var rotHor_velocity_abs = abs(rotHor_velocity)
	var dir = sign(rotHor_velocity)
	if rotHorReleased and rotHor_velocity_abs > 0:
		rotHor_velocity -= dir * rotHor_deceleration * _delta
		if rotHor_velocity_abs < 0.0005:
			rotHor_velocity = 0
		
		pivot_panning.rotate_y(rotHor_velocity)

#endregion
	
	rotHor_isRotating = rotHor_velocity_abs > 0

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
			height_velocity -= sign(height_velocity) * height_deceleration * _delta

			if abs(height_velocity) < 0.01:
				height_velocity = 0
	
	#Apply velocity
	var targetHeight = cam.global_position.y
	targetHeight += height_velocity * _delta
	targetHeight = clampf(targetHeight,height_limit_Min,height_limit_Max)
	cam.global_position.y = targetHeight
	
func _FOV():
	if fov_changeByHeight:
		var height01 = inverse_lerp(height_limit_Min,height_limit_Max,cam.global_position.y)
		var targetFov = lerpf(fov_min,fov_max,height01)
		cam.fov = targetFov
		
