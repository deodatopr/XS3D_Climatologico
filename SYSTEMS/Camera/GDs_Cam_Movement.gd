class_name GDs_CamMovement extends Node

@export var raycast : RayCast3D
@export var mshRotBottom : Node3D
@export var triggerRaycast  : Area3D

@onready var mat_vfx_camRot : StandardMaterial3D = preload("uid://djj8aafmjyy0h")

var cam : Camera3D
var pivot_panning : Node3D
var distFromPivotCam : float

#Inclination
var inclination : float

#FOV
var fov_bottom : float

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

const ROTVERT_THRESHOLD : float = 0.8
const ROTHOR_THRESHOLD : float = 0.8

var canMoveCam : bool
var tweenMovCamera : Tween
var tweenMshVfxRotCam : Tween
#var tweenEffects : Tween
#var worldEnv : WorldEnvironment
#var environment : Environment
#var camAttribute : CameraAttributes

func Initialize(_cam : Camera3D, _pivot_panning : Node3D, _modeConfig : GDs_CR_Cam_ModeConfig):
	triggerRaycast.area_entered.connect(_OnTriggerEntered)
	triggerRaycast.area_exited.connect(_OnTriggerExit)
	
	cam = _cam
	pivot_panning = _pivot_panning
	#worldEnv = _worldEnv
	#environment = worldEnv.environment
	#camAttribute = worldEnv.camera_attributes
	distFromPivotCam = _modeConfig.distFromPivotCam
	
	SetModeConfig(_modeConfig)
	
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
	
	#Rotation
	rotHor_allow = _modeConfig.rotHor_allow
	rotHor_speed = _modeConfig.rotHor_speed
	rotHor_deceleration = _modeConfig.rotHor_deceleration
	
	#Height
	height_limit_bottom = _modeConfig.height_limit_bottom
	height_limit_top = _modeConfig.height_limit_top
	height_speed = _modeConfig.height_speed
	height_deceleration = _modeConfig.height_deceleration

func SetModeConfig(_modeConfig : GDs_CR_Cam_ModeConfig):
	canMoveCam = false
	#Cam
	# Height
	var initHeight : float = clampf(_modeConfig.initialHeight, _modeConfig.height_limit_bottom, _modeConfig.height_limit_top)
	var targetHeight : Vector3
	targetHeight.y = initHeight
	
	if APPSTATE.camMode == ENUMS.Cam_Mode.Bottom:
		#Bottom
		var offsetFromPivot : Vector3 = pivot_panning.global_position + (-pivot_panning.basis.z * distFromPivotCam)
		targetHeight.x = offsetFromPivot.x
		targetHeight.z = offsetFromPivot.z
	else:
		#Top
		targetHeight.x = pivot_panning.global_position.x
		targetHeight.z = pivot_panning.global_position.z
	
	# Degress
	var targetDegress = cam.rotation_degrees
	targetDegress.x = _modeConfig.inclination
	
	var typeEaseTop = Tween.EASE_OUT
	var typeTransitionTop = Tween.TRANS_EXPO
	
	var typeEaseBottom = Tween.EASE_IN_OUT
	var typeTransitionBottom =  Tween.TRANS_QUAD
	
	tweenMovCamera = get_tree().create_tween().set_parallel(true)
	#tweenEffects = get_tree().create_tween().set_parallel(true)
	#
	#tweenEffects.tween_property(environment,"adjustment_saturation",.2,.7)
	#tweenEffects.chain().tween_property(environment,"adjustment_saturation",1,.7)
	
	if APPSTATE.camMode == ENUMS.Cam_Mode.Top:
		tweenMovCamera.tween_property(cam,"global_position",targetHeight, 1.5).set_ease(typeEaseTop).set_trans(typeTransitionTop)
		tweenMovCamera.tween_property(cam,"fov",_modeConfig.fov, 1).set_ease(typeEaseTop).set_trans(typeTransitionTop)
		tweenMovCamera.tween_property(cam,"rotation_degrees",targetDegress, 1.5).set_ease(typeEaseTop).set_trans(typeTransitionTop)
	else:
		tweenMovCamera.tween_property(cam,"global_position",targetHeight, 1.5).set_ease(typeEaseBottom).set_trans(typeTransitionBottom)
		tweenMovCamera.tween_property(cam,"fov",_modeConfig.fov, 1).set_ease(typeEaseBottom).set_trans(typeTransitionBottom)
		tweenMovCamera.tween_property(cam,"rotation_degrees",targetDegress, 1.5).set_ease(typeEaseBottom).set_trans(typeTransitionBottom)

	#tweenMovCamera.tween_property(environment,"adjustment_saturation",1,.5)
	OnUpdateCRCam(_modeConfig)
	
	await tweenMovCamera.finished
	canMoveCam = true

func _physics_process(delta):
	if not canMoveCam:
		return 
	
	_Panning(delta)

	_Height(delta)
	_HeightByCollision(delta)
		
	if rotHor_allow:
		_Rotation_Hor(delta)

func _OnTriggerEntered(_area3d : Area3D):
	UTILITIES.TurnOnObject(raycast)

func _OnTriggerExit(_area3d : Area3D):
	UTILITIES.TurnOffObject(raycast)

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
	
	#Save global input to use in other systems (minimap)
	APPSTATE.camInputPan = inputDir
	
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
	
	#Msh_Rot_Bottom
	if APPSTATE.camMode == ENUMS.Cam_Mode.Bottom and not rotHorReleased:
		UTILITIES.TurnOnObject(mshRotBottom)
		
		mat_vfx_camRot.albedo_color.a = 0
		var originalColor : Color =  mat_vfx_camRot.albedo_color
		var targetColor : Color =  originalColor
		targetColor.a = 1 
		tweenMshVfxRotCam = get_tree().create_tween()
		tweenMshVfxRotCam.tween_property(mat_vfx_camRot,'albedo_color',targetColor, 0.25)
	else:
		if mshRotBottom.visible:
			var originalColor : Color =  mat_vfx_camRot.albedo_color
			var targetColor : Color =  originalColor
			targetColor.a = 0
			tweenMshVfxRotCam = get_tree().create_tween()
			tweenMshVfxRotCam.tween_property(mat_vfx_camRot,'albedo_color',targetColor, 0.3)
			
			await tweenMshVfxRotCam.finished
			UTILITIES.TurnOffObject(mshRotBottom)

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
	
	# Apply velocity in the forward direction
	var forward_vector : Vector3 = cam.global_transform.basis.z.normalized()
	
	# Apply the new position to the camera
	var targetPos : Vector3 = cam.global_position
	targetPos += forward_vector * height_velocity * _delta
	
	if targetPos.y >= height_limit_bottom and targetPos.y <= height_limit_top:
		cam.global_position = targetPos
	else:
		height_velocity = 0

		
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
		height_velocity = 200 * _delta
		var targetHeight = cam.global_position.y
		targetHeight += height_velocity * _delta
		targetHeight = clampf(targetHeight,height_limit_bottom,height_limit_top)
		cam.global_position.y = targetHeight
		
	#Decrease height
	if heightColl_collided and not raycast.is_colliding():
		#(static value (70) to avoid more properties in cam config)
		height_velocity = -400 * _delta
		var targetHeight = cam.global_position.y
		targetHeight += height_velocity * _delta
		targetHeight = clampf(targetHeight,height_limit_bottom,height_limit_top)
		cam.global_position.y = targetHeight
		
		if (cam.global_position.y - heightColl_lastHeightBeforeCollided) < 0.005:
			heightColl_collided = false
			cam.global_position.y = heightColl_lastHeightBeforeCollided
