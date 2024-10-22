class_name GDs_AerialMovement extends Node

@export var mshMarkRot : Node3D
@export var pivot_rotLeft : Node3D
@export var pivot_rotRight : Node3D

@onready var mat_fx_camRot : StandardMaterial3D = preload("uid://rohx5pwh5cc2")

var camMng : GDs_Cam_Manager
var cam : Camera3D
var pivot_cam : Node3D

#FOV
var currentFov : float

#Movement
var mov_speed : float
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
var tweenMovCamera : Tween
var tweenMshVfxRotCam : Tween
var curvAccl : Curve
var curvDecl : Curve

const ROTHOR_THRESHOLD : float = 0.8

func Initialize(_camMng : GDs_Cam_Manager):
	camMng = _camMng
	cam = camMng.cam
	pivot_cam = camMng.pivot_cam
	
	UpdateCamConfig()
	
func UpdateCamConfig():
	cam.global_position.y = camMng.aerial_height
	cam.rotation_degrees.x = -camMng.aerial_camRotAngle
	cam.fov = camMng.aerial_fov
	currentFov = camMng.aerial_fov
	
	#Set pivots to rotate around them
	var pivotPos : Vector3 = cam.global_position
	pivotPos.y = 0	
	var rightVector : Vector3 = cam.basis.x.normalized()
	pivot_rotLeft.position = pivotPos + rightVector * camMng.aerial_distPivotsRot
	pivot_rotRight.position = pivotPos + -rightVector * camMng.aerial_distPivotsRot
	
	#Movement
	mov_speed = camMng.aerial_flying_speed * 10
	mov_max_acceleration = mov_speed
	mov_deceleration = mov_max_acceleration * 1.3
	mov_speed_boost = 5
	
	curvAccl = camMng.aerial_curveAccel
	curvDecl = camMng.aerial_curveDecel
	
	
func _physics_process(delta):
	_Panning(delta)
	
	_Fov(delta)
	
	_Rotation_Vert(delta)
	
	_ShowMshMarkPivot(true)
	
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
		var currentSpeed : float = (mov_speed * mov_speed_boost) if Input.is_action_pressed('3DMove_SpeedBoost') else mov_speed
		mov_velocity = inputDir * currentSpeed * _delta

		#Limit acceleration
		var curvePoint : float = UTILITIES.GetCurvePoint(curvAccl,.5,_delta)
		mov_velocity = mov_velocity.limit_length(5 * curvePoint)
	elif not mov_isPressingMove and mov_isMoving:
		#Deceleration
		var curvePoint : float = UTILITIES.GetCurvePoint(curvDecl,.4,_delta,true)
		mov_velocity = mov_velocity.limit_length(mov_velocity.length() * curvePoint)

	#Apply
	var targetPosition : Vector3 = pivot_cam.global_position
	targetPosition += mov_velocity
	pivot_cam.global_position = targetPosition
	
	mov_isMoving = mov_velocity.length() > 0
	

	
func _Rotation_Vert(_delta : float):
		if Input.is_action_pressed("3DMove_RotVert_+"):
			cam.global_rotation.x += 1 * camMng.aerial_camRot_Speed * _delta
		if Input.is_action_pressed("3DMove_RotVert_-"):
			cam.global_rotation.x += -1 * camMng.aerial_camRot_Speed * _delta
		
		if Input.is_action_pressed("3DMove_RotVert_+") or  Input.is_action_pressed("3DMove_RotVert_-"):
			var minRotVer : float = deg_to_rad(-80)
			var maxRotVert : float = deg_to_rad(-45) 
			cam.global_rotation.x = clampf(cam.rotation.x,minRotVer, maxRotVert) 

func _Fov(_delta : float):
	if Input.is_action_pressed("3DMove_Fov_+") or Input.is_action_just_pressed("3DMove_Fov_+"):
		currentFov += 50 * _delta
		currentFov = clampf(currentFov, camMng.aerial_fov_min, camMng.aerial_fov_max)
		cam.fov = currentFov
	if Input.is_action_pressed("3DMove_Fov_-") or Input.is_action_just_pressed("3DMove_Fov_-"):
		currentFov -= 50 * _delta
		currentFov = clampf(currentFov, camMng.aerial_fov_min, camMng.aerial_fov_max)
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
