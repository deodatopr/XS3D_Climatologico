class_name GDs_AerialMovement extends Node

@export var mshMarkRot : Node3D
@export var pivot_rotLeft : Node3D
@export var pivot_rotRight : Node3D

@onready var mat_fx_camRot : StandardMaterial3D = preload("uid://rohx5pwh5cc2")

var cam : Camera3D
var pivot_cam : Node3D

#FOV
var currentFov : float

#Movement
var mov_currentBoost : float
var mov_speed_boost : float
var mov_deceleration : float
var mov_max_acceleration : float
var mov_velocity : Vector3
var mov_isMoving : bool
var mov_isPressingMove : bool

#Rotation
var rotHor_isRotating : bool

# Misc
var curvIsRunning : bool
var canMoveCam : bool
var signalUpdateWasEmitted : bool
var aerialConfig : GDs_AerialConfig
var tweenMovCamera : Tween
var tweenMshVfxRotCam : Tween
var curAcceleration : Curve
var curDeceleration : Curve

var currentCurvValue : float
var curvAccelerationReset : bool
var curvDecelerationReset : bool

const ROTHOR_THRESHOLD : float = 0.8

func Initialize(_cam : Camera3D, _pivot_cam : Node3D, _aerialConfig : GDs_AerialConfig):
	cam = _cam
	pivot_cam = _pivot_cam
	
	UpdateCamConfig(_aerialConfig)
	
	#Set initial values
	cam.global_position.y = aerialConfig.height
	cam.rotation_degrees.x = aerialConfig.rotation
	cam.fov = aerialConfig.fov_initial
	currentFov = aerialConfig.fov_initial
	
	var rightVector : Vector3 = pivot_cam.basis.x.normalized()
	pivot_rotLeft.position = rightVector * aerialConfig.distPivotsRot
	pivot_rotRight.position = -rightVector * aerialConfig.distPivotsRot
	
func UpdateCamConfig(_aerialConfig : GDs_AerialConfig):
	aerialConfig = _aerialConfig
	
	#Movement
	mov_max_acceleration = aerialConfig.movement_speed
	mov_deceleration = aerialConfig.movement_speed * 1.3
	mov_speed_boost = 5
	
	curAcceleration = aerialConfig.curvAcceleration
	curDeceleration = aerialConfig.curvDeceleration
	
func _physics_process(delta):
	_Panning(delta)
	
	_Fov(delta)
	
	_Rotation_Vert(delta)
	_Rotation_Hor(delta)
	
	_ShowMshMarkPivot(mov_isMoving or rotHor_isRotating)
	
	if (mov_isMoving or rotHor_isRotating) and not signalUpdateWasEmitted:
		SIGNALS.OnCameraUpdate.emit(true)
		signalUpdateWasEmitted = true
	elif (not mov_isMoving and not rotHor_isRotating and mov_velocity.length() == 0) and signalUpdateWasEmitted:
		SIGNALS.OnCameraUpdate.emit(false)
		signalUpdateWasEmitted = false

func _Panning(_delta:float):
	var inputDir = Vector3.ZERO
	
	if Input.is_action_pressed("3DMove_Forward") or rotHor_isRotating:
		inputDir += -cam.global_basis.z
	
	if Input.is_action_pressed("3DMove_Backward"):
		inputDir += cam.global_basis.z
		
	inputDir.y = 0
	
	#Save global input to use in other systems (minimap)
	APPSTATE.camInputPan = inputDir
	mov_isPressingMove = inputDir.length() > 0
	
	#Acceleration
	if mov_isPressingMove:
		var currentSpeed : float = (aerialConfig.movement_speed * mov_speed_boost) if Input.is_action_pressed('3DMove_SpeedBoost') else aerialConfig.movement_speed
		mov_velocity = inputDir * currentSpeed * _delta

		#Limit acceleration
		var curvePoint : float = UTILITIES.GetCurvePoint(curAcceleration,.5,_delta)
		mov_velocity = mov_velocity.limit_length(mov_velocity.length() * curvePoint)
	elif not mov_isPressingMove and mov_isMoving:
		#Deceleration
		var curvePoint : float = UTILITIES.GetCurvePoint(curDeceleration,.4,_delta,true)
		mov_velocity = mov_velocity.limit_length(mov_velocity.length() * curvePoint)

	#Apply
	var targetPosition : Vector3 = pivot_cam.global_position
	targetPosition += mov_velocity
	pivot_cam.global_position = targetPosition
	
	mov_isMoving = mov_velocity.length() > 0
	
func _Rotation_Hor(_delta : float):
	var pivotToRotate : Node3D
	
	if Input.is_action_pressed("3DMove_RotHor_-"):
		pivotToRotate = _ParentToRotate(-1)
		var curvePoint : float = UTILITIES.GetCurvePoint(curAcceleration,.5,_delta)
		var rotationOffset : float = 1 * aerialConfig.rotHor_speed * _delta
		pivotToRotate.rotate_y(rotationOffset * curvePoint)
	if Input.is_action_pressed("3DMove_RotHor_+"):
		pivotToRotate = _ParentToRotate(1)
		var curvePoint : float = UTILITIES.GetCurvePoint(curAcceleration,.5,_delta)
		var rotationOffset : float = -1 * aerialConfig.rotHor_speed * _delta
		pivotToRotate.rotate_y(rotationOffset * curvePoint)
	
	rotHor_isRotating = Input.is_action_pressed("3DMove_RotHor_-") or Input.is_action_pressed("3DMove_RotHor_+")
	if not rotHor_isRotating:
		_ParentToRotate(0)
	
			
func _Rotation_Vert(_delta : float):
		if Input.is_action_pressed("3DMove_RotVert_+"):
			cam.global_rotation.x += -1 * aerialConfig.rotHor_speed * _delta
		if Input.is_action_pressed("3DMove_RotVert_-"):
			cam.global_rotation.x += 1 * aerialConfig.rotHor_speed * _delta
		
		if Input.is_action_pressed("3DMove_RotVert_+") or  Input.is_action_pressed("3DMove_RotVert_-"):
			var minRotVer : float = deg_to_rad(-80)
			var maxRotVert : float = deg_to_rad(-45) 
			cam.global_rotation.x = clampf(cam.rotation.x,minRotVer, maxRotVert) 

func _Fov(_delta : float):
	if Input.is_action_pressed("3DMove_Fov_+") or Input.is_action_just_pressed("3DMove_Fov_+"):
		currentFov += 50 * _delta
		currentFov = clampf(currentFov, aerialConfig.fov_min, aerialConfig.fov_max)
		cam.fov = currentFov
		cam.fov = clampf(currentFov, aerialConfig.fov_min, aerialConfig.fov_max)
	if Input.is_action_pressed("3DMove_Fov_-") or Input.is_action_just_pressed("3DMove_Fov_-"):
		currentFov -= 50 * _delta
		currentFov = clampf(currentFov, aerialConfig.fov_min, aerialConfig.fov_max)
		cam.fov = currentFov

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

func _ParentToRotate(_rotatingDir : int) -> Node3D:
	if _rotatingDir == 1:
		cam.reparent(pivot_rotRight)
		return pivot_rotRight
	elif _rotatingDir == -1:
		cam.reparent(pivot_rotLeft)
		return pivot_rotLeft
	else:
		cam.reparent(pivot_cam)
		return null

func _ResetVelocities():
	mov_velocity = Vector3.ZERO
