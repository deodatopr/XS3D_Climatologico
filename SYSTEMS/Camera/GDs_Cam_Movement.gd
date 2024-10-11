class_name GDs_CamMovement extends Node

@export var raycast : RayCast3D

var cam : Camera3D
var pivot_panning : Node3D

#Panning
var pan_currentBoost : float
var pan_boost : float
var pan_acceleration : float
var pan_deceleration : float
var pan_max_acceleration : float
var pan_velocity : Vector3 = Vector3.ZERO

var pan_bounding_X_min : float
var pan_bounding_X_max : float
var pan_bounding_Z_min : float
var pan_bounding_Z_max : float

#Inclination
var incl_curve : Curve
var incl_bottom : float
var incl_top : float

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

#Height
var height_speed
var height_deceleration

var height_velocity : float
var height_dir : int
var height_validDir : int

var height_limit_top : float
var height_limit_bottom : float

#Height by collision
var heightColl_collided : bool
var heightColl_lastHeightBeforeCollided : float

#FOV
var fov_bottom : float
var fov_top : float

const ROTVERT_THRESHOLD : float = 0.8
const ROTHOR_THRESHOLD : float = 0.8

func Initialize(_cam : Camera3D, _pivot_panning : Node3D, _modeConfig : GDs_CR_Cam_ModeConfig):
	cam = _cam
	pivot_panning = _pivot_panning
	_SetModeConfig(_modeConfig)
	
func OnUpdateCRCam(_modeConfig : GDs_CR_Cam_ModeConfig):
	#Reset velocities
	pan_velocity = Vector3.ZERO
	rotHor_velocity = 0
	height_velocity = 0
	
	#Pannning
	pan_acceleration = _modeConfig.pan_acceleration
	pan_max_acceleration = _modeConfig.pan_max_acceleration
	pan_boost = _modeConfig.pan_boostSpeed
	pan_deceleration = _modeConfig.pan_deceleration
	
	pan_bounding_X_min = _modeConfig.boundings_X_min
	pan_bounding_X_max = _modeConfig.boundings_X_max
	pan_bounding_Z_min = _modeConfig.boundings_Z_min
	pan_bounding_Z_max = _modeConfig.boundings_Z_max
	
	#Inclination
	incl_curve = _modeConfig.incl_curve
	incl_bottom = _modeConfig.incl_bottom
	incl_top = _modeConfig.incl_top
	
	#Rotation
	rotHor_allow = _modeConfig.rotHor_allow
	rotHor_speed = _modeConfig.rotHor_speed
	rotHor_deceleration = _modeConfig.rotHor_deceleration
	
	#Height
	height_limit_bottom = _modeConfig.height_limit_bottom
	height_limit_top = _modeConfig.height_limit_top
	height_speed = _modeConfig.height_speed
	height_deceleration = _modeConfig.height_deceleration
	
	#FOV
	fov_bottom = _modeConfig.fov_height_bottom
	fov_top = _modeConfig.fov_height_top

func _physics_process(delta):
	_Panning(delta)
	
	_Inclination()
	
	_Height(delta)
	_HeightByCollision(delta)
	
	_FOV()
		
	if rotHor_allow:
		_Rotation_Hor(delta)

func _SetModeConfig(_modeConfig : GDs_CR_Cam_ModeConfig):
	#Cam	
	var initHeight : float = clampf(_modeConfig.initialHeight, _modeConfig.height_limit_bottom, _modeConfig.height_limit_top)
	cam.global_position.y = initHeight
	
	OnUpdateCRCam(_modeConfig)

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
		pan_currentBoost = pan_boost if Input.is_action_pressed("3DMove_SpeedBoost") else 0.0
		pan_velocity += (inputDir * pan_acceleration * _delta) + pan_velocity.normalized() * pan_currentBoost
		
		#Limit pan_acceleration
		if pan_velocity.length() > pan_max_acceleration:
			pan_velocity = pan_velocity.limit_length(pan_max_acceleration + pan_currentBoost)
			
		SIGNALS.OnCameraUpdate.emit(true)

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

func _Inclination():
	var height01 : float = APPSTATE.camHeight01
	height01 *= incl_curve.sample(1 - height01)
	var targetInclination : float = lerp(incl_bottom,incl_top,height01)
	cam.rotation_degrees.x = -targetInclination
		
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
			SIGNALS.OnCameraUpdate.emit(true)
			
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
			SIGNALS.OnCameraUpdate.emit(true)
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
			SIGNALS.OnCameraUpdate.emit(false)
		
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
		if height_dir == 0 and abs(height_velocity) > 0:
			height_velocity -= sign(height_velocity) * height_deceleration * _delta

			if abs(height_velocity) < 0.01:
				height_velocity = 0
	
	#Apply velocity
	var targetHeight = cam.global_position.y
	targetHeight += height_velocity * _delta
	targetHeight = clampf(targetHeight,height_limit_bottom,height_limit_top)
	cam.global_position.y = targetHeight
	
	#Save global camHeight01
	APPSTATE.camHeight01 = inverse_lerp(height_limit_bottom,height_limit_top,cam.global_position.y)

func _HeightByCollision(_delta : float):
	raycast.enabled = pan_velocity.length() > 0
	
	#Increase height
	if raycast.enabled and raycast.is_colliding():
		#Save last height
		if not heightColl_collided:
			heightColl_collided = true
			heightColl_lastHeightBeforeCollided = cam.global_position.y
		
		#Increasing height 
		#(static value (80) to avoid more properties in cam config)
		height_velocity = 80 * _delta
		var targetHeight = cam.global_position.y
		targetHeight += height_velocity * _delta
		targetHeight = clampf(targetHeight,height_limit_bottom,height_limit_top)
		cam.global_position.y = targetHeight
		
	#Decrease height
	if heightColl_collided and not raycast.is_colliding():
		#(static value (70) to avoid more properties in cam config)
		height_velocity = -1 * 70 * _delta
		var targetHeight = cam.global_position.y
		targetHeight += height_velocity * _delta
		targetHeight = clampf(targetHeight,height_limit_bottom,height_limit_top)
		cam.global_position.y = targetHeight
		
		if (cam.global_position.y - heightColl_lastHeightBeforeCollided) < 0.005:
			heightColl_collided = false
			cam.global_position.y = heightColl_lastHeightBeforeCollided

func _FOV():
	var targetFov = lerpf(fov_bottom,fov_top,APPSTATE.camHeight01)
	cam.fov = targetFov
