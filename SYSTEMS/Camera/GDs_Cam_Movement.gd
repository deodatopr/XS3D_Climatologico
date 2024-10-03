class_name GDs_CamMovement extends Node

var cam : Node3D
var pivot_panning : Node3D
var speed_Pan : float
var speed_RotHor : float
var speed_RotVert : float
var speed_Zoom : float
var allow_RotVert : bool

var currentMouseVelocity : Vector2

func Initialize(_cam : Camera3D, _pivot_panning : Node3D):
	cam = _cam
	pivot_panning = _pivot_panning
	
func SetModeConfig(_modeConfig : GDs_CR_Cam_ModeConfig):
	cam.global_position.y = _modeConfig.initialHeight
	cam.rotation_degrees.x = _modeConfig.inclination
	speed_Pan = _modeConfig.speed_panning
	speed_RotHor = _modeConfig.speed_rotHor
	speed_RotVert = _modeConfig.speed_rotVert
	speed_Zoom = _modeConfig.speed_zoom
	allow_RotVert = _modeConfig.allow_RotVert

func _physics_process(delta):
	_Panning(delta)
	_Height(delta)
	_Rotation_Hor(delta)
	
	#if allow_RotVert:
		#_Rotation_Vert(delta)

func _Panning(_delta:float):
	if Input.is_action_pressed("3DMove_Forward"):
		pivot_panning.global_position += (pivot_panning.basis.z * speed_Pan * _delta)
	
	if Input.is_action_pressed("3DMove_Backward"):
		pivot_panning.global_position += (-pivot_panning.basis.z * speed_Pan * _delta)
		
	if Input.is_action_pressed("3DMove_Right"):
		pivot_panning.global_position += (-pivot_panning.basis.x * speed_Pan * _delta)
	
	if Input.is_action_pressed("3DMove_Left"):
		pivot_panning.global_position += (pivot_panning.basis.x * speed_Pan * _delta)
		
func _Rotation_Hor(_delta : float):
	#Mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouseDir = Input.get_last_mouse_velocity()
		var dirRotX = sign(mouseDir.x)
		
		if abs(mouseDir.x) > 0.1:
			pivot_panning.rotate_y(-dirRotX * speed_RotHor * _delta)
	
	#Control
	var joy_id = 0 
	if Input.is_joy_known(joy_id):
		var axisX = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_X)

		if abs(axisX) > 0.1:
			pivot_panning.rotate_y(-axisX * speed_RotHor * _delta)
			
func _Rotation_Vert(_delta : float):
	#Mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouseDir = Input.get_last_mouse_velocity()
		var dirRotY = sign(mouseDir.y)
		
		if abs(mouseDir.y) > 0.1:
			cam.rotation_degrees.x += (-dirRotY * speed_RotVert * _delta)
	
	#Control
	var joy_id = 0 
	if Input.is_joy_known(joy_id):
		var axisY = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_Y)

		if abs(axisY) > 0.1:
			cam.rotation_degrees.x += (-axisY * speed_RotVert * _delta)

func _Height(_delta : float):
	if Input.is_action_pressed("3DMove_Height_+") or Input.is_action_just_released("3DMove_Height_+"):
		cam.global_position.y +=  speed_Zoom * _delta
		
	if Input.is_action_pressed("3DMove_Height_-") or Input.is_action_just_released("3DMove_Height_-"):
		cam.global_position.y -= speed_Zoom * _delta
