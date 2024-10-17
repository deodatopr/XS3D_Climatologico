class_name GDs_CamMovement extends Node

@export var raycast : RayCast3D
@export var mshMarkRot : Node3D
@export var triggerRaycast  : Area3D

@onready var mat_fx_camRot : StandardMaterial3D = preload("uid://rohx5pwh5cc2")

var cam : Camera3D
var pivot_panning : Node3D
var cr_cam_config : GDs_CR_Cam_Config
var navMeshRegion : NavigationRegion3D

var camModeBottom : bool:
	get:
		return APPSTATE.camMode == ENUMS.Cam_Mode.Bottom
		
#Cameras
var camFocus : float
var transition_speed : float
var fov : float
var tilt : float
var debug_lookAt : bool
var debug_pivotMsh : bool
var debug_fov : bool

#Height
var height : float
var height_deceleration : float

var height_speed : float
var height_velocity : float
var height_dir : int
var height_validDir : int

var height_limit_top : float
var height_limit_bottom : float

#Panning
var mov_currentBoost : float
var mov_speed_boost : float
var mov_speed : float
var mov_deceleration : float
var mov_max_acceleration : float
var mov_velocity : Vector3 = Vector3.ZERO
var mov_isMoving : bool

var bounding_X_min : float
var bounding_X_max : float
var bounding_Z_min : float
var bounding_Z_max : float

#Rotation
var rotHor_speed : float

var rotHor_initDirCaptured : bool
var rotHor_initdir : Vector2
var rotHor_currentDir : Vector2
var rotHor_isRotating : bool

#Height by collision
var heightColl_collided : bool
var heightColl_lastHeightBeforeCollided : float

#Tweens
var canMoveCam : bool
var tweenMovCamera : Tween
var tweenMshVfxRotCam : Tween

var typeEaseTop : int = Tween.EASE_IN_OUT
var typeTransitionTop: int  = Tween.TRANS_QUAD

var typeEaseBottom: int  = Tween.EASE_IN_OUT
var typeTransitionBottom: int  =  Tween.TRANS_QUAD

var signalUpdateWasEmitted : bool

const ROTHOR_THRESHOLD : float = 0.8

#func Initialize(_cam : Camera3D, _pivot_panning : Node3D, _cr_cam_config : GDs_CR_Cam_Config, _navMeshRegion : NavigationRegion3D):
func Initialize(_cam : Camera3D, _pivot_panning : Node3D, _cr_cam_config : GDs_CR_Cam_Config):
	triggerRaycast.area_entered.connect(_OnTriggerEntered)
	triggerRaycast.area_exited.connect(_OnTriggerExit)
	
	cam = _cam
	pivot_panning = _pivot_panning
	cr_cam_config = _cr_cam_config
	#navMeshRegion = _navMeshRegion
	
	SetModeConfig()

func UpdateProperties():
	#Reset velocities
	_ResetVelocities()
	
	#Debug
	debug_lookAt = cr_cam_config.debug_alwaysLookAt
	debug_pivotMsh = cr_cam_config.debug_alwaysPivotMsh
	debug_fov = cr_cam_config.debug_alwaysFov
	
	#Pivot dist
	camFocus = cr_cam_config.bottom_focus
	transition_speed = cr_cam_config.transition_speed
	
	#Height
	height = cr_cam_config.bottom_height if camModeBottom else  cr_cam_config.top_height
	height_speed = 700 if camModeBottom else  1400
	
	var zoom_range = height * .25
	height_limit_bottom = height - zoom_range
	height_limit_top = height + zoom_range
	height_deceleration = height_speed * .035
	
	#Fov
	fov =  cr_cam_config.bottom_fov if camModeBottom else  cr_cam_config.top_fov
	
	#Tilt
	tilt = -26 if camModeBottom else  -90
	
	#Movement
	mov_speed = cr_cam_config.bottom_mov_speed if camModeBottom else  cr_cam_config.top_mov_speed
	mov_max_acceleration = mov_speed * .75
	mov_speed_boost = mov_speed
	mov_deceleration = mov_speed - 5
	
	bounding_X_min = cr_cam_config.boundings_X_min
	bounding_X_max = cr_cam_config.boundings_X_max
	bounding_Z_min = cr_cam_config.boundings_Z_min
	bounding_Z_max = cr_cam_config.boundings_Z_max
	
	#Rotation
	rotHor_speed = 1.6

func SetModeConfig():
	canMoveCam = false
	
	UpdateProperties()
	
	#Cam
	var camPosTarget : Vector3 = Vector3.ZERO
	camPosTarget.y = height
	
	if camModeBottom:
		#Bottom
		var offsetFromPivot : Vector3 = pivot_panning.global_position + (-pivot_panning.basis.z * camFocus)
		camPosTarget.x = offsetFromPivot.x
		camPosTarget.z = offsetFromPivot.z
	else:
		#Top
		camPosTarget.x = pivot_panning.global_position.x
		camPosTarget.z = pivot_panning.global_position.z
	
	# Tilt
	var targetDegress : Vector3 = cam.rotation_degrees
	
	targetDegress.x = tilt
	
	tweenMovCamera = get_tree().create_tween().set_parallel(true)
	if camModeBottom:
		tweenMovCamera.tween_property(cam,"global_position",camPosTarget, transition_speed).set_ease(typeEaseBottom).set_trans(typeTransitionBottom)
		tweenMovCamera.tween_property(cam,"fov",fov, transition_speed - .5).set_ease(typeEaseBottom).set_trans(typeTransitionBottom)
		tweenMovCamera.tween_property(cam,"rotation_degrees",targetDegress, transition_speed).set_ease(typeEaseBottom).set_trans(typeTransitionBottom)
	else:
		tweenMovCamera.tween_property(cam,"global_position",camPosTarget, transition_speed).set_ease(typeEaseTop).set_trans(typeTransitionTop)
		tweenMovCamera.tween_property(cam,"fov",fov, transition_speed -.5).set_ease(typeEaseTop).set_trans(typeTransitionTop)
		tweenMovCamera.tween_property(cam,"rotation_degrees",targetDegress, transition_speed).set_ease(typeEaseTop).set_trans(typeTransitionTop)

	
	await tweenMovCamera.finished
	canMoveCam = true

func _physics_process(delta):
	if not canMoveCam:
		return 
		
	#TEST: Probando ir a punto, esto llegará por alguna señal
	if Input.is_key_pressed(KEY_SPACE):
		_GoToPoint(Vector3.ZERO)
	
	#TEST: Ver angulo necesario con la distancia de cam a pivot y la altura
	if debug_lookAt and camModeBottom:
		_LookAt()
		
	#TEST: Update siempre FOV al cambiarlo en el CR
	if debug_fov:
		cam.fov = fov
	
	_Panning(delta)

	_Height(delta)
	#_HeightByCollision(delta)
		
	_Rotation_Hor(delta)
	
	_ShowMshMarkPivot(mov_isMoving or rotHor_isRotating or debug_pivotMsh)
	
	if (mov_isMoving or rotHor_isRotating) and not signalUpdateWasEmitted:
		SIGNALS.OnCameraUpdate.emit(true)
		signalUpdateWasEmitted = true
	elif (not mov_isMoving and not rotHor_isRotating) and signalUpdateWasEmitted:
		SIGNALS.OnCameraUpdate.emit(false)
		signalUpdateWasEmitted = false

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
	mov_isMoving = inputDir.length()
	
	#Acceleration
	if inputDir.length() > 0:
		mov_currentBoost = mov_speed_boost if Input.is_action_pressed("3DMove_SpeedBoost") else 0.0
		mov_velocity += (inputDir * mov_speed * _delta) + mov_velocity.normalized() * mov_currentBoost
		
		#Limit mov_speed
		if mov_velocity.length() > mov_max_acceleration:
			mov_velocity = mov_velocity.limit_length(mov_max_acceleration + mov_currentBoost)
	else:
		#Deceleration
		if mov_velocity.length() > 0:
			mov_velocity -= mov_velocity.normalized() * mov_deceleration * _delta
			if mov_velocity.length() < 0.1:
				mov_velocity = Vector3.ZERO
	
	#Apply
	var targetPosition : Vector3 = pivot_panning.global_position
	targetPosition += mov_velocity * _delta
	targetPosition.x = clampf(targetPosition.x, bounding_X_min, bounding_X_max)
	targetPosition.z = clampf(targetPosition.z, bounding_Z_min, bounding_Z_max)
	
	var isInBoundX = abs(pivot_panning.global_position.x -  bounding_X_min) < 0.01 or abs(pivot_panning.global_position.x -  bounding_X_max) < 0.01
	var isInBoundZ = abs(pivot_panning.global_position.z -  bounding_Z_min) < 0.01 or abs(pivot_panning.global_position.z -  bounding_Z_max) < 0.01
	
	if isInBoundX || isInBoundZ:
		mov_velocity = Vector3.ZERO
	
	pivot_panning.global_position = targetPosition
		
func _LookAt():
	var camPosTarget : Vector3 = Vector3.ZERO
	camPosTarget.y = height
	
	#Bottom
	var offsetFromPivot : Vector3 = pivot_panning.global_position + (-pivot_panning.basis.z * camFocus)
	camPosTarget.x = offsetFromPivot.x
	camPosTarget.z = offsetFromPivot.z
	
	cam.global_position = camPosTarget
	cam.look_at(pivot_panning.global_position)

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
			pivot_panning.rotate_y(-mouseDirRotX * rotHor_speed * _delta)
			
	if rotHor_initDirCaptured and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		rotHor_initDirCaptured = false
#endregion
	
#region [ CONTROL ]
	#Control
	var joy_id = 0 
	if Input.is_joy_known(joy_id):
		var control_Dir = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_X)

		if abs(control_Dir) > ROTHOR_THRESHOLD:
			pivot_panning.rotate_y(-control_Dir * rotHor_speed * _delta)
#endregion
	
#Check if there are no input pressed
	if Input.is_joy_known(joy_id) and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		rotHor_isRotating =  abs(Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_X)) > .4
	else:
		rotHor_isRotating = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

func _ShowMshMarkPivot(_show : bool):
	#Msh_Rot_Bottom
	if _show:
		UTILITIES.TurnOnObject(mshMarkRot)
		
		mat_fx_camRot.albedo_color.a = 0
		var originalColor : Color =  mat_fx_camRot.albedo_color
		var targetColor : Color =  originalColor
		targetColor.a = 1 
		tweenMshVfxRotCam = get_tree().create_tween()
		tweenMshVfxRotCam.tween_property(mat_fx_camRot,'albedo_color',targetColor, 0.25)
	else:
		if mshMarkRot.visible:
			var originalColor : Color =  mat_fx_camRot.albedo_color
			var targetColor : Color =  originalColor
			targetColor.a = 0
			tweenMshVfxRotCam = get_tree().create_tween()
			tweenMshVfxRotCam.tween_property(mat_fx_camRot,'albedo_color',targetColor, 0.3)
			
			await tweenMshVfxRotCam.finished
			UTILITIES.TurnOffObject(mshMarkRot)

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

		
#func _HeightByCollision(_delta : float):
	#navMeshRegion.
			
func _GoToPoint(_targetPoint : Vector3):
	_targetPoint.y = 0
	canMoveCam = false
	
	_ResetVelocities()
	tweenMovCamera = create_tween()
	var setEase : int = Tween.EASE_IN_OUT
	var setTrans : int = Tween.TRANS_EXPO
	
	tweenMovCamera.tween_property(pivot_panning,"global_position",_targetPoint, 1.5).set_ease(setEase).set_trans(setTrans)
	await tweenMovCamera.finished
	
	canMoveCam = true
	
func _ResetVelocities():
	mov_velocity = Vector3.ZERO
	height_velocity = 0
