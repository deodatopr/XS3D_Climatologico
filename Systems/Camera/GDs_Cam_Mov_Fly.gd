class_name GDs_Cam_Mov_Fly extends Node

var camMng : GDs_Cam_Manager

var cam : Camera3D
var pivot : Node3D

var mov_deceleration : float
var mov_velocity : Vector3 = Vector3.ZERO

var yaw : float = 0.0
var pitch : float = 0.0
var MouseMotion : InputEvent
var is_start_to_move : bool = false
var last_cam_rotation : Vector3
var last_pivot_rotation : Vector3
var return_cam_time_elpased : float = 0
var last_pitch : float = 0
var yaw_direction = 1
var BoostTimeElapsed = 0
var CursorMovement : Vector2
var isInGround : bool = false
var isInTop : bool = false
var canPressDown : bool = true
var speed01 : float = 0
var lastSpeed01 : float = 0

const RETURN_CAMERA_ADJUST : float = 0.1

func Initialize(_camMng : GDs_Cam_Manager):
	camMng = _camMng
	cam = camMng.fly_cam
	pivot = camMng.fly_pivot
	mov_deceleration = camMng.fly_speed_accel_decel

	
func SetCamera():
	cam.current = true
	pivot.global_position.y = camMng.fly_initialHeight
	cam.position = Vector3.ZERO
	cam.rotation_degrees = Vector3(0, 180, 0)
	cam.fov = camMng.fly_fov
	
	
func UpdateCamConfig():
	cam.fov = camMng.fly_fov
	
func _input(event):
	if event is InputEventMouseMotion:
		MouseMotion = event
	else:
		MouseMotion = null

func _physics_process(delta:float):
	_movement(delta)
	_rotation(delta)
	
	#Check boundings map01
	camMng.CheckMapBoundings(pivot)
	
func obtenr_bouns_navrmsh(navmesh):
	var total_aabb = AABB()
	
	for node in navmesh.get_children():
		if node is not MeshInstance3D:
			for meshnode in node.get_children(): 
				if meshnode is NavigationRegion3D:
					var vertices = meshnode.navmesh.get_vertices()  # Obtener todos los vértices del NavMesh
					
					if vertices.is_empty():
						return null 
				
					var min_pos = vertices[0]
					var max_pos = vertices[0]
					
					for vertex in vertices:
						min_pos = Vector3(min(vertex.x, min_pos.x), min(vertex.y, min_pos.y), min(vertex.z, min_pos.z))
						max_pos = Vector3(max(vertex.x, max_pos.x), max(vertex.y, max_pos.y), max(vertex.z, max_pos.z))

					# Crear el AABB con los límites obtenidos
					var size = max_pos - min_pos
					total_aabb = total_aabb.merge(AABB(min_pos, size))
		
	return total_aabb
	
func _movement(_delta:float):
	var inputDir = Vector3.ZERO

	if Input.is_action_pressed("3DMove_Forward"):
		inputDir += pivot.basis.z

	if Input.is_action_pressed("3DMove_Backward"):
		inputDir += -pivot.basis.z

	if Input.is_action_pressed("3DMove_Right"):
		inputDir += -pivot.basis.x

	if Input.is_action_pressed("3DMove_Left"):
		inputDir += pivot.basis.x
		
	if Input.is_action_pressed("3DMove_Up"):
		if !isInTop:
			inputDir += pivot.basis.y
			isInGround = false

	if Input.is_action_pressed("3DMove_Down"):
		if canPressDown:
			inputDir -= pivot.basis.y
			isInTop = false

	var FinalSpeedTurbo : float = camMng.fly_boost
	FinalSpeedTurbo = camMng.fly_boost if Input.is_action_pressed("3DMove_SpeedBoost") else 1
	
	if inputDir.length() > 0:
		mov_velocity += (inputDir * camMng.fly_speed * _delta) + mov_velocity.normalized() * (FinalSpeedTurbo)
		if mov_velocity.length() > camMng.fly_speed_accel_decel:	
			mov_velocity = mov_velocity.limit_length(camMng.fly_speed_accel_decel * FinalSpeedTurbo)
	
	else:
		if mov_velocity.length() > 0:
			mov_velocity -= mov_velocity.normalized() * mov_deceleration * _delta
			if mov_velocity.length() < 0.1:
				mov_velocity = Vector3.ZERO	
				BoostTimeElapsed = 0
	
	var fixSpeed : float =  inverse_lerp(0,camMng.fly_speed * camMng.fly_boost,mov_velocity.length())
	var slowSpeed : float = lerpf(lastSpeed01,fixSpeed, .2)
	speed01 = clampf(slowSpeed,0,1 if Input.is_action_pressed('3DMove_SpeedBoost') else .7)
	lastSpeed01 = speed01
	
	var targetPosition : Vector3 = pivot.global_position
	targetPosition += mov_velocity * _delta
	
	var distanceToGround = targetPosition.distance_to(UTILITIES._get_point_on_map(targetPosition, cam,0))
	isInGround = distanceToGround < camMng.fly_minDistGround
	var pointInNavMesh := UTILITIES._get_point_on_map(cam.global_position, cam,0).y
	canPressDown = pivot.global_position.y > pointInNavMesh + camMng.fly_minDistGround - 4
	
	if isInGround:
		if targetPosition.y - UTILITIES._get_point_on_map(targetPosition, cam,0).y > .1:
			if inputDir != Vector3.UP:
				targetPosition.y = lerpf(targetPosition.y, pointInNavMesh + (Vector3.UP * (camMng.fly_minDistGround - 5)).y, .5)
		else:
			targetPosition.y = pointInNavMesh + (Vector3.UP * 50).y

	isInTop = targetPosition.y >= camMng.fly_maxFlyingDist
	
	pivot.global_position = targetPosition


func _rotation(_delta:float):
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if MouseMotion != null:
			if MouseMotion.relative.x > 0:
				yaw_direction = 1
			else:
				yaw_direction = -1
			CursorMovement += MouseMotion.relative * 2
			CursorMovement.y = clampf(CursorMovement.y, -(DisplayServer.screen_get_size()*1.0).y/2, (DisplayServer.screen_get_size()*1.0).y/2)
			CursorMovement.x = clampf(CursorMovement.x, -(DisplayServer.screen_get_size()*1.0).x/2, (DisplayServer.screen_get_size()*1.0).x/2)
			_rotHorPivot((CursorMovement.x*2)/DisplayServer.screen_get_size().x * 10, _delta)
			_rotVertCam((CursorMovement.y*2)/DisplayServer.screen_get_size().y * 10, _delta)
		else:
			_rotHorPivot((CursorMovement.x*2)/DisplayServer.screen_get_size().x * 10, _delta)
			_rotVertCam((CursorMovement.y*2)/DisplayServer.screen_get_size().y * 10, _delta)

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		CursorMovement = Vector2.ZERO
		
	if Input.is_action_pressed("3DLook_Up") or Input.is_action_pressed("3DLook_Down"):
		_rotVertCam(-Input.get_axis("3DLook_Down", '3DLook_Up') * 10, _delta)
	elif not (Input.is_action_pressed("3DLook_Up") or Input.is_action_pressed("3DLook_Down")) and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_rotVertReturn(_delta)
		
	if Input.is_action_pressed("3DLook_Right") or Input.is_action_pressed("3DLook_Left"):
		yaw_direction = -Input.get_axis("3DLook_Right", '3DLook_Left')
		_rotHorPivot(yaw_direction * 10, _delta)
	elif not (Input.is_action_pressed("3DLook_Right") or Input.is_action_pressed("3DLook_Left")) and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		yaw -= ((camMng.fly_rot_hor_speed * (yaw_direction * 10)) * UTILITIES.GetCurvePoint(camMng.curveMovement, 1.2, _delta, true)) * _delta
		pivot.rotation_degrees.y = yaw

func _rotHorPivot(dir:float, _delta:float):
	yaw -= dir * camMng.fly_rot_hor_speed  * _delta
	pivot.rotation_degrees.y = yaw

func _rotVertCam(dir:float, _delta:float):
	if not is_start_to_move:
		return_cam_time_elpased = 0
		is_start_to_move = true
		pitch = last_pitch
		
	pitch -= dir * camMng.fly_rot_vert_speed  * _delta
	last_pitch = pitch
	pitch = clampf(pitch, -camMng.fly_vert, camMng.fly_vert)
	cam.rotation_degrees.x = pitch
		
func _rotVertReturn(_delta:float):
	if abs(cam.rotation_degrees.x) > .1:
		cam.rotation_degrees.x = lerpf(cam.rotation_degrees.x, 0, return_cam_time_elpased / (camMng.fly_vert_return / RETURN_CAMERA_ADJUST))
		return_cam_time_elpased += _delta
		last_pitch = cam.rotation_degrees.x
		is_start_to_move = false
	else:
		cam.rotation_degrees.x = 0
		pitch = 0
		last_pitch = 0