class_name GDs_CamAereaMovement extends Node

@export var mshMarkRot : Node3D

@onready var mat_fx_camRot : StandardMaterial3D = preload("uid://rohx5pwh5cc2")
@export var mng : GDs_Cam_Manager

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
var canMoveCam : bool
var signalUpdateWasEmitted : bool
var camAereaConfig : GDs_CamAereaConfig
var tweenMovCamera : Tween
var tweenMshVfxRotCam : Tween

const ROTHOR_THRESHOLD : float = 0.8

func Initialize(_cam : Camera3D, _pivot_cam : Node3D, _camAereaConfig : GDs_CamAereaConfig):
	cam = _cam
	pivot_cam = _pivot_cam
	camAereaConfig = _camAereaConfig
	
	#Set initial values
	cam.position.y = camAereaConfig.height_initial
	cam.rotation_degrees.x = camAereaConfig.tilt_initial
	cam.fov = camAereaConfig.fov_initial
	currentFov = camAereaConfig.fov_initial	
	
	UpdateCamConfig(_camAereaConfig)
	
func UpdateCamConfig(_camAereaConfig : GDs_CamAereaConfig):
	camAereaConfig = _camAereaConfig
	
	#Movement
	mov_max_acceleration = camAereaConfig.movement_speed
	mov_deceleration = camAereaConfig.movement_speed * 1.3
	mov_speed_boost = 5
	
	
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
	
	if Input.is_action_pressed("3DMove_Forward"):
		inputDir += -cam.basis.z
	
	if Input.is_action_pressed("3DMove_Backward"):
		inputDir += cam.basis.z
		
	inputDir.y = 0
	#Save global input to use in other systems (minimap)
	APPSTATE.camInputPan = inputDir	
	mov_isPressingMove = inputDir.length() > 0
	
	#Acceleration
	if inputDir.length() > 0:
		var currentSpeed : float = (camAereaConfig.movement_speed * mov_speed_boost) if Input.is_action_pressed('3DMove_SpeedBoost') else camAereaConfig.movement_speed
		mov_velocity += inputDir * currentSpeed * _delta
		
		#Limit mov_speed
		mov_velocity = mov_velocity.limit_length(mov_max_acceleration + currentSpeed)
	else:
		#Deceleration
		if mov_velocity.length() > 0:
			mov_velocity -= mov_velocity.normalized() * mov_deceleration * _delta
			if mov_velocity.length() < 0.1:
				mov_velocity = Vector3.ZERO

	#Apply
	var targetPosition : Vector3 = pivot_cam.global_position
	targetPosition += mov_velocity
	pivot_cam.global_position = targetPosition
	
	mov_isMoving = mov_velocity.length() > 0
	
func _Rotation_Hor(_delta : float):
	if mov_isPressingMove and mov_velocity.length() >= camAereaConfig.movement_speed:
		if Input.is_action_pressed("3DMove_RotHor_-"):
			cam.rotate_y(1 * camAereaConfig.rotHor_speed * _delta)
		if Input.is_action_pressed("3DMove_RotHor_+"):
			cam.rotate_y(-1 * camAereaConfig.rotHor_speed * _delta)
			
func _Rotation_Vert(_delta : float):
		if Input.is_action_pressed("3DMove_RotVert_+"):
			cam.global_rotation.x += -1 * camAereaConfig.rotHor_speed * _delta
		if Input.is_action_pressed("3DMove_RotVert_-"):
			cam.global_rotation.x += 1 * camAereaConfig.rotHor_speed * _delta
		
		if Input.is_action_pressed("3DMove_RotVert_+") or  Input.is_action_pressed("3DMove_RotVert_-"):
			var minRotVer : float = deg_to_rad(-80)
			var maxRotVert : float = deg_to_rad(-45) 
			cam.global_rotation.x = clampf(cam.rotation.x,minRotVer, maxRotVert) 

func _Fov(_delta : float):
	if Input.is_action_pressed("3DMove_Fov_+") or Input.is_action_just_pressed("3DMove_Fov_+"):
		currentFov += 50 * _delta
		currentFov = clampf(currentFov, camAereaConfig.fov_min, camAereaConfig.fov_max)
		cam.fov = currentFov
		cam.fov = clampf(currentFov, camAereaConfig.fov_min, camAereaConfig.fov_max)
	if Input.is_action_pressed("3DMove_Fov_-") or Input.is_action_just_pressed("3DMove_Fov_-"):
		currentFov -= 50 * _delta
		currentFov = clampf(currentFov, camAereaConfig.fov_min, camAereaConfig.fov_max)
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
	
func _ResetVelocities():
	mov_velocity = Vector3.ZERO
