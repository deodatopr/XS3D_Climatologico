class_name GDs_Cam_Mov_Fly extends Node

var camMng : GDs_Cam_Manager

var cam : Camera3D
var pivot : Node3D

var mov_axisMovement : Vector2
var mov_curv01 : float
var mov_speed01 : float
var mov_deceleration : float = 100
var mov_velocity : Vector3
var mov_lastVelocity : Vector3
var mov_lastBounding01 : float
var mov_lastSpeed01 : float

var mov_height_axis : float
var mov_height_last : float
var mov_height_velocity : float
var mov_height_lerp : float
var mov_height_isInGround : bool
var mov_height_isInTop : bool

var rot_hor : float
var rot_vert : float
var rot_lastRotX : float
var rot_lastRotY : float
var rot_lastDir : Vector2
var rot_axisRotation : Vector2

var mouseMotion : InputEvent
var cursorMovement : Vector2
var curvPoint : float

func Initialize(_camMng : GDs_Cam_Manager):
	camMng = _camMng
	cam = camMng.fly_cam
	pivot = camMng.fly_pivot
	rot_hor = pivot.rotation.y
	rot_vert = pivot.rotation.x

func SetCamera():
	cam.current = true
	pivot.global_position.y = camMng.fly_height_start
	cam.fov = camMng.fly_fov
	
func UpdateCamConfig():
	cam.fov = camMng.fly_fov
	
func _input(event):
	if event is InputEventMouseMotion:
		mouseMotion = event
	else:
		mouseMotion = null

func _physics_process(delta:float):
	_movement(delta)
	_rotation(delta)
	
	#Check boundings map01
	camMng.CheckMapBoundings(pivot)
	
func _movement(_delta:float):
	_mov_height(_delta)
	_mov_movement(_delta)
	
func _mov_height(_delta : float):
	#Get input from  mouse/ controller
	mov_height_axis = Input.get_axis("3DMove_Height_-","3DMove_Height_+")
	var heightDir : float = signf(mov_height_axis)
	
	#Set limits
	var minHeightFromNavMesh : float = camMng.GetPointOnMap(pivot.position,0).y
	@warning_ignore('shadowed_global_identifier')
	var min : float = minHeightFromNavMesh + camMng.fly_height_min
	@warning_ignore('shadowed_global_identifier')
	var max : float = minHeightFromNavMesh + camMng.fly_height_max
	var height01 : float = clampf(inverse_lerp(min,max,pivot.global_position.y),0,1)
	
	#Calculate new height
	mov_height_velocity = heightDir * 700 * _delta
	
	#Apply new height to an aux vector to evaluate distances
	var targetHeight : Vector3 = pivot.position
	targetHeight.y += mov_height_velocity
	
	#Check distance to ground
	var limitHeight01ToDetectGround : float = .2
	var limitHeight01ToDetectTop: float = .8
	mov_height_isInGround = height01 <= limitHeight01ToDetectGround
	mov_height_isInTop = height01 >= limitHeight01ToDetectTop
	if mov_height_isInGround and heightDir < 0:
		mov_height_lerp = 1 - inverse_lerp(limitHeight01ToDetectGround,0,height01)
	elif mov_height_isInTop and heightDir > 0:
		mov_height_lerp = inverse_lerp(1,limitHeight01ToDetectTop,height01)
	else:
		mov_height_lerp = 1
	
	mov_height_velocity *= mov_height_lerp
	
	#Apply
	var finalHeight : float = pivot.position.y
	finalHeight += mov_height_velocity
	finalHeight = clampf(finalHeight,min,max)
	
	var smoothness :float = 5
	pivot.position.y = lerpf(pivot.position.y, finalHeight, smoothness *_delta)
	mov_height_last = pivot.position.y

func _mov_movement(_delta : float):
	mov_axisMovement = Input.get_vector("3DMove_Right","3DMove_Left","3DMove_Backward","3DMove_Forward")
	var dir : Vector3 = (pivot.basis * Vector3(mov_axisMovement.x,0,mov_axisMovement.y).normalized())
	
	if mov_axisMovement.y < 0:
		dir.y = 0
	
	@warning_ignore('incompatible_ternary')
	var isPressingTurbo : bool = Input.is_action_pressed("3DMove_SpeedBoost")
	
	@warning_ignore('incompatible_ternary')
	var currentTurbo : float = camMng.fly_turbo if isPressingTurbo else 1
	
	if dir.length() > 0:
		if mov_curv01 < 1:
			#Calculate curve acc
			mov_curv01 += camMng.fly_acce_dece * _delta
			mov_curv01 = clampf(mov_curv01,0,1)
			curvPoint = camMng.curveMovement.sample(mov_curv01)
		
		#Calculate velocity to move
		mov_velocity += dir * camMng.fly_speed * curvPoint * _delta
		@warning_ignore('incompatible_ternary')
		var mov_limitSpeed : float = camMng.fly_speed * currentTurbo
		mov_velocity = mov_velocity.limit_length(mov_limitSpeed)
	elif dir.length() == 0 and mov_velocity.length() > 0:
		#Calculate curve dec
		mov_curv01 -= camMng.fly_acce_dece * _delta
		mov_curv01 = clampf(mov_curv01,0,1)
		curvPoint = camMng.curveMovement.sample(mov_curv01)
		
		#Calculate deceleration
		var targetLength : Vector3 = mov_velocity * curvPoint
		mov_velocity = lerp(mov_velocity, targetLength,curvPoint)
		if mov_velocity.length() < .001:
			mov_velocity = Vector3.ZERO
			
	#Velocity decrease by boundings
	var decreaseSpeedByLimits : float = (1 - CAM.boundings01)
	var isDirTowardLimit : bool = signf(mov_lastBounding01 - decreaseSpeedByLimits) > 0
	
	#No decrease speed if dir is diferent toward limit (to escape easily)
	if not isDirTowardLimit:
		decreaseSpeedByLimits = 1

	mov_lastBounding01 = (1 - CAM.boundings01)
	mov_velocity = mov_velocity * decreaseSpeedByLimits

	#Save speed01 to send it to UI
	var fixSpeed : float =  inverse_lerp(0,camMng.fly_speed  * camMng.fly_turbo,mov_velocity.length())
	var slowSpeed : float = lerpf(mov_lastSpeed01,fixSpeed, 10 * _delta)
	mov_speed01 = clampf(slowSpeed,0, 1)
	mov_lastSpeed01 = mov_speed01
	
	#Apply move
	if mov_velocity.length() > 0:
		mov_lastVelocity = mov_velocity
		mov_velocity = mov_velocity
		pivot.global_position += mov_velocity

	
func _rotation(_delta:float):
	#Detect input controller
	rot_axisRotation = Input.get_vector("3DLook_Left",'3DLook_Right','3DLook_Down','3DLook_Up')
	var dir : Vector2 = rot_axisRotation
	
	#Detect input mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if mouseMotion != null:
			var fixedMouseMotion : Vector2 = mouseMotion.relative
			fixedMouseMotion.y = -fixedMouseMotion.y
			dir = fixedMouseMotion.normalized()

	CAM.isRotating = dir.length() > 0
	
	dir = lerp(rot_lastDir,dir,5 *_delta)
	
	#Apply rot
	_rotation_hor(dir.x,_delta)
	_rotation_vert(-dir.y,_delta)

	rot_lastRotX = pivot.rotation.x
	rot_lastRotY = pivot.rotation.y
	rot_lastDir = dir

func _rotation_hor(_dir:float, _delta:float):
	rot_hor -= _dir * camMng.fly_rot_speed  * _delta
	var targetAngle : float = rot_hor
	var smoothTarget : float = lerp_angle(rot_lastRotY,targetAngle,15 * _delta)
	pivot.rotation.y = smoothTarget

func _rotation_vert(_dir:float, _delta:float):
	var toEvaluateAngle : float = rot_vert
	toEvaluateAngle -= -_dir * camMng.fly_rot_speed  * _delta
	toEvaluateAngle = clampf(toEvaluateAngle,deg_to_rad(-camMng.fly_rot_clamp),deg_to_rad(camMng.fly_rot_clamp) )
	rot_vert = toEvaluateAngle
	var targetAngle : float = rot_vert
	var smoothTarget : float = lerp_angle(rot_lastRotX,targetAngle,15 * _delta)
	
	pivot.rotation.x = smoothTarget
