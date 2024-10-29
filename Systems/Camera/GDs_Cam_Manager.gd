class_name GDs_Cam_Manager extends Node

@export var valuesInRuntime : bool

@export_group("SCENE REFERENCES")
@export var worldEnv : WorldEnvironment
@export var ui_ppe_sky : Node3D
@export var ui_ppe_fly : Node3D

@export_group("INTERNAL REFERENCES")
@export var curveMovement : Curve
@export var movSky : GDs_Cam_Mov_Sky
@export var sky_pivot : Node3D
@export var sky_cam : Camera3D
@export var movFly : GDs_Cam_Mov_Fly
@export var fly_pivot : Node3D
@export var fly_cam : Camera3D
@export var Terrains: Array [Node3D]

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
@onready var env_sky : Environment = preload("uid://buu228l4r1lse")
@onready var env_fly : Environment = preload("uid://d0njvq6rqh23r")

var NavMeshBounds : AABB
var camMode : int
var last_rotation : float

var sky_UI_maxSpeed : int = 250
var fly_UI_maxSpeed : int = 100

func _ready():
	var rndMode : RandomNumberGenerator = RandomNumberGenerator.new()
	var rndNumber : int = rndMode.randi_range(0,100)
	camMode = ENUMS.Cam_Mode.fly if rndNumber % 2 == 0 else ENUMS.Cam_Mode.sky
	
	Initialize(camMode)
	
func Initialize(_modeToIntializeCam : int):
	APPSTATE.camMode = _modeToIntializeCam
	movSky.Initialize(self)
	movFly.Initialize(self)
	
	for terrain in Terrains:
		NavMeshBounds = NavMeshBounds.merge(UTILITIES.get_scene_bounds(terrain))
	
	_ChangeToMode(_modeToIntializeCam)
	
func _input(_event):
	if Input.is_action_just_pressed('3DMove_ChangeCamMode'):
		camMode = ENUMS.Cam_Mode.fly if APPSTATE.camMode == ENUMS.Cam_Mode.sky else ENUMS.Cam_Mode.sky
		SIGNALS.OnCameraRequestChangeMode.emit(camMode)
		
		await SIGNALS.OnCameraCanChangeMode
		
		APPSTATE.camMode = camMode
		_ChangeToMode(APPSTATE.camMode)

func _PositionOnMap(pivot:Node3D) ->Vector2:
	var cam_in_world = (pivot.global_position + (NavMeshBounds.size/2))/NavMeshBounds.size
	return Vector2(1 - cam_in_world.x, 1 - cam_in_world.z)

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
		# World env
		worldEnv.environment = env_sky
	
		# UI + PPE
		UTILITIES.TurnOnObject(ui_ppe_sky)
		UTILITIES.TurnOffObject(ui_ppe_fly)
	
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
		# World env
		worldEnv.environment = env_fly
		
		# UI + PPE
		UTILITIES.TurnOffObject(ui_ppe_sky)
		UTILITIES.TurnOnObject(ui_ppe_fly)
	
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
