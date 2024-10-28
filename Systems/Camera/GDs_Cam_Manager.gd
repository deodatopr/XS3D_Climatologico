class_name GDs_Cam_Manager extends Node

@export var valuesInRuntime : bool

@export_group("INTERNAL REFERENCES")
@export var curveMovement : Curve
@export var movSky : GDs_Cam_Mov_Sky
@export var sky_pivot : Node3D
@export var sky_cam : Camera3D
@export var movFly : GDs_Cam_Mov_Fly
@export var fly_pivot : Node3D
@export var fly_cam : Camera3D

@export_group("CAMERA SKY")
@export_subgroup("Movements")
@export var sky_height : float = 500
@export var sky_move: float = .5
@export_range(1,2) var sky_boost: float = 2

@export_subgroup("Camera")
@export var sky_camRot_speed : float = 1

@export_range(30,130) var sky_zoom_in : float = 30
@export var sky_zoom_out : float = 100

@export_group("CAMERA FLY")
@export var fly_initialHeight : float = 80
@export var fly_speed_accel_decel : float = 100
@export var fly_speed : float = 200
@export_range(1,5) var fly_boost : float = 2
@export var fly_rot_hor_speed : float = 7
@export var fly_rot_vert_speed : float = 5
@export_range(0, 90) var fly_vert : float = 45
@export var fly_vert_return : float = .5
@export_range(15, 90) var fly_minDistGround : float = 55
@export var fly_maxFlyingDist : float = 250
@export_range(30,100) var fly_fov :float = 35

@onready var mat_roads : BaseMaterial3D = preload("uid://bcn6j5aje8ydi")

@export_group("DRON CAMERA")
@export var dron_initialHeight : float = 300
@export var dron_speed_accel_decel : float = 200
@export var dron_speed : float = 200
@export_range(1,5) var dron_boost : float = 2
@export var dron_rot_hor_speed : float = 2.5
@export var dron_rot_vert_speed : float = 5
@export_range(0, 90) var dron_vert : float = 45
@export var dron_vert_return : float = 1
@export_range(15, 90) var dron_minDistGround : float = 55
@export var dron_maxFlyingDist : float = 700
@export_range(30,100) var dron_fov :float = 50
@export var Terrains: Array [Node3D]


var camMode : int
var sky_UI_maxSpeed : int = 250
var fly_UI_maxSpeed : int = 100
var last_rotation : float

func _ready():
	var rndMode : RandomNumberGenerator = RandomNumberGenerator.new()
	var rndNumber : int = rndMode.randi_range(0,100)
	camMode = ENUMS.Cam_Mode.fly if rndNumber % 2 == 0 else ENUMS.Cam_Mode.sky
	
	Initialize(camMode)
	
func Initialize(_modeToIntializeCam : int):
	APPSTATE.camMode = _modeToIntializeCam
	movSky.Initialize(self)
	movFly.Initialize(self)
	
	_ChangeToMode(_modeToIntializeCam)
	
func _input(_event):
	if Input.is_action_just_pressed('3DMove_ChangeCamMode'):
		camMode = ENUMS.Cam_Mode.fly if APPSTATE.camMode == ENUMS.Cam_Mode.sky else ENUMS.Cam_Mode.sky
		SIGNALS.OnCameraRequestChangeMode.emit(camMode)
		
		await SIGNALS.OnCameraCanChangeMode
		
		APPSTATE.camMode = camMode
		_ChangeToMode(APPSTATE.camMode)

func _process(_delta):
	_UpdateCamState()
	
	if valuesInRuntime:
		if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
			movSky.UpdateCamConfig()
		else:
			movFly.UpdateCamConfig()
	
func _UpdateCamState():
	var cam : Camera3D = sky_cam if APPSTATE.camMode == ENUMS.Cam_Mode.sky else fly_cam 
	var pivot : Node3D = sky_pivot if APPSTATE.camMode == ENUMS.Cam_Mode.sky else fly_pivot 
	var dir = sign(cam.global_rotation_degrees.y)
	var fixRotY = abs(floori(cam.global_rotation_degrees.y - 180)) 
	
	if abs(ceili(cam.global_rotation_degrees.y - 180)) == 360:
		CAM.rotation = Vector2(floori(cam.global_rotation_degrees.x), 0)
	elif dir > 0:
		CAM.rotation = Vector2(floori(cam.global_rotation_degrees.x),ceili(fixRotY))
	elif dir < 0:
		CAM.rotation = Vector2(floori(cam.global_rotation_degrees.x),ceili(abs(fixRotY - 360)))
	

	CAM.height = ceili(cam.global_position.y)
	CAM.fov = ceili(cam.fov)
	CAM.position = cam.global_position
	
	last_rotation = cam.global_rotation_degrees.y
	
	if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
		CAM.speed = floori(lerpf(0,sky_UI_maxSpeed, movSky.speed01))
	else:
		CAM.speed = floori(lerpf(0,fly_UI_maxSpeed, movFly.speed01))
		
func _ChangeToMode(_mode : int):
	if _mode == ENUMS.Cam_Mode.sky:
		_ChangeToMode_Sky()
	else:
		_ChangeToMode_Free()
		
func _ChangeToMode_Sky():
		#Turn on sky cam
		movSky.process_mode = Node.PROCESS_MODE_ALWAYS
		UTILITIES.TurnOnObject(sky_pivot)
		
		#Turn off free cam
		movFly.process_mode = Node.PROCESS_MODE_DISABLED
		UTILITIES.TurnOffObject(fly_pivot)
		
		#Apply initial values
		movSky.SetCamera()
		
		#Roads
		mat_roads.albedo_color.a = 1
		
func _ChangeToMode_Free():
		#Turn off sky cam
		movSky.process_mode = Node.PROCESS_MODE_DISABLED
		UTILITIES.TurnOffObject(sky_pivot)
		
		#Turn on free cam
		movFly.process_mode = Node.PROCESS_MODE_ALWAYS
		UTILITIES.TurnOnObject(fly_pivot)
		
		#Apply initial values
		movFly.SetCamera()
		
		#Roads
		mat_roads.albedo_color.a = .3
