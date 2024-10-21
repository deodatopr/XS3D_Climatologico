extends Node

@export_group("Components")
@export var cam : Node3D
@export var pivot : Node3D

@export_group("Properties")
@export var mov_currentBoost : float
@export var mov_speed_boost : float
@export var mov_speed : float
@export var mov_max_acceleration : float
@export var rot_speed : float
@export var rot_hor_speed : float
@export var max_pitch : float = 90.0
@export var min_pitch : float = -90.0
@export var return_camera_speed : float = 1
@export var curveSpeed : Curve

var mov_deceleration : float
var mov_velocity : Vector3 = Vector3.ZERO

var yaw : float = 0.0
var pitch : float = 0.0
var MouseMotion : InputEvent
var is_start_to_move : bool = false
var last_cam_rotation : Vector3
var last_pivot_rotation : Vector3
var return_cam_time_elpased : float = 0

const RETURN_CAMERA_ADJUST : float = 0.1

func Initialize(_cam : Camera3D, _pivot : Node3D):
	cam = _cam
	pivot = _pivot
	
func _ready():
	mov_deceleration = mov_max_acceleration
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		MouseMotion = event
	else:
		MouseMotion = null

func _physics_process(delta:float):
	_movement(delta)
	_rotation(delta)

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
		print("Up")
		pivot.global_position += Vector3.UP * mov_speed * _delta

	if Input.is_action_pressed("3DMove_Down"):
		pivot.global_position += Vector3.DOWN * mov_speed * _delta

	if inputDir.length() > 0:
		mov_currentBoost = mov_speed_boost if Input.is_action_pressed("3DMove_SpeedBoost") else 0.0
		mov_velocity += (-inputDir * mov_speed * _delta) + mov_velocity.normalized() * mov_currentBoost
		
		if mov_velocity.length() > mov_max_acceleration:
					mov_velocity = mov_velocity.limit_length(mov_max_acceleration + mov_currentBoost)
	else:
		if mov_velocity.length() > 0:
			mov_velocity -= mov_velocity.normalized() * mov_deceleration * _delta
			if mov_velocity.length() < 0.1:
				mov_velocity = Vector3.ZERO
		
	var targetPosition : Vector3 = pivot.global_position
	targetPosition += mov_velocity * _delta

	pivot.global_position = targetPosition

func _rotation(_delta:float):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		if not is_start_to_move:
			last_cam_rotation = cam.rotation_degrees
			last_pivot_rotation = pivot.rotation_degrees
			return_cam_time_elpased = 0
			is_start_to_move = true
			
		if MouseMotion != null:
			print(MouseMotion.relative.x)
			yaw -= MouseMotion.relative.x * rot_hor_speed  * _delta
			pitch -= MouseMotion.relative.y * rot_speed * _delta

			pitch = clampf(pitch, min_pitch, max_pitch)

			pivot.rotation_degrees.y = yaw
			cam.rotation_degrees.x = pitch

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cam.rotation_degrees.x = lerpf(cam.rotation_degrees.x, last_cam_rotation.x, return_cam_time_elpased / (return_camera_speed / RETURN_CAMERA_ADJUST))
		pivot.rotation_degrees.y = lerpf(pivot.rotation_degrees.y, last_pivot_rotation.y, return_cam_time_elpased / (return_camera_speed / RETURN_CAMERA_ADJUST))
		return_cam_time_elpased += _delta
		yaw = 0
		pitch = 0
		is_start_to_move = false
