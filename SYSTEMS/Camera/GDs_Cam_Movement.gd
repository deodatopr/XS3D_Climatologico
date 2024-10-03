class_name GDs_CamMovement extends Node

var cam : Camera3D
var pivot_panning : Node3D
var speed_Pan : float
var speed_RotHor : float

func Initialize(_cam : Camera3D, _pivot_panning : Node3D, _speed_Pan : float, _speed_RotHor):
	cam = _cam
	pivot_panning = _pivot_panning
	speed_Pan = _speed_Pan
	speed_RotHor = _speed_RotHor

func _physics_process(delta):
	_Panning(delta)
	_Rotation(delta)

func _Panning(_delta:float):
	if Input.is_action_pressed("3DMove_Forward"):
		pivot_panning.global_position += (pivot_panning.basis.z * speed_Pan * _delta)
	
	if Input.is_action_pressed("3DMove_Backward"):
		pivot_panning.global_position += (-pivot_panning.basis.z * speed_Pan * _delta)
		
	if Input.is_action_pressed("3DMove_Right"):
		pivot_panning.global_position += (-pivot_panning.basis.x * speed_Pan * _delta)
	
	if Input.is_action_pressed("3DMove_Left"):
		pivot_panning.global_position += (pivot_panning.basis.x * speed_Pan * _delta)
		
func _Rotation(_delta : float):
	#Mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouseDir = Input.get_last_mouse_velocity()
		var dirRotY = sign(mouseDir.x)
		
		if abs(mouseDir.x) > 0.1:
			pivot_panning.rotate_y(-dirRotY * speed_RotHor * _delta)
	
	#Control
	var joy_id = 0 
	if Input.is_joy_known(joy_id):
		var right_x = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_X)

		if abs(right_x) > 0.1:
			pivot_panning.rotate_y(-right_x * speed_RotHor * _delta)
