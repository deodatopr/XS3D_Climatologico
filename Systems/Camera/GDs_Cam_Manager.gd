class_name GDs_Cam_Manager extends Node

@export var valuesInRuntime : bool

@export_group("SCENE REFERENCES")
@export var worldEnv : WorldEnvironment
@export var msh_roads : MeshInstance3D
@export var msh_limit : MeshInstance3D
@export var ppe_fishEye_DroneSky : ColorRect

@export var ui_ppe_sky : Node
@export var ui_ppe_fly : Node

@export var ligtht_sun_sky : Node3D
@export var ligtht_sun_fly : Node3D

@export_group("INTERNAL REFERENCES")
@export var movSky : GDs_Cam_Mov_Sky
@export var sky_pivot : Node3D
@export var sky_cam : Camera3D
@export var movFly : GDs_Cam_Mov_Fly
@export var fly_pivot : Node3D
@export var fly_cam : Camera3D
@export var Terrains: Array [Node3D]

@export_group("CAMERAS")
@export var curveMovement : Curve
@export_range(.75,1) var limitToStartGlich01 : float = .8

@export_subgroup("SKY")
@export var sky_height : float = 500
@export var sky_speed: float = .5
@export_range(1,2) var sky_turbo: float = 2
@export var sky_rot_speed : float = 1
@export_range(30,130) var sky_zoom_in : float = 30
@export var sky_zoom_out : float = 100

@export_subgroup("FLY")
@export_range(30,100) var fly_fov :float = 35
@export var fly_height_start : float = 80
@export var fly_height_max : float = 250
@export var fly_height_min : float = 55
@export var fly_speed : float = 200
@export_range(1,5) var fly_turbo : float = 2
@export var fly_rot_speed : float = .75

@onready var mat_limit_sky : ShaderMaterial = preload("uid://b5mdctmpig2lv")
@onready var mat_limit_fly : ShaderMaterial = preload("uid://nan3iase8pij")

@onready var mat_roads_sky : BaseMaterial3D = preload("uid://bybsj0rkirn0u")
@onready var mat_roads_fly : BaseMaterial3D = preload("uid://bcn6j5aje8ydi")

@onready var preset_env_sky : Environment = preload("uid://buu228l4r1lse")
@onready var preset_env_fly : Environment = preload("uid://d0njvq6rqh23r")

@onready var preset_cam_sky : CameraAttributesPractical = preload("uid://ddf3muiyuuvj6")
@onready var preset_cam_fly : CameraAttributesPractical = preload("uid://b6jeytnq38xvp")

var navMeshBounds : AABB
var camMode : int
var last_rotation : float

var sky_UI_maxSpeed : int = 250
var fly_UI_maxSpeed : int = 100

var dangerToCloseLimit : bool
var positionInMap01 : Vector2 = Vector2.ZERO
var matFishEye :  ShaderMaterial

func _ready():
	#TEST: Incio en modo random
	#var rndMode : RandomNumberGenerator = RandomNumberGenerator.new()
	#var rndNumber : int = rndMode.randi_range(0,100)
	#camMode = ENUMS.Cam_Mode.fly if rndNumber % 2 == 0 else ENUMS.Cam_Mode.sky
	
	#TEST: Siempre inicia en sky o fly
	camMode = ENUMS.Cam_Mode.fly
	
	Initialize(camMode)
	
func Initialize(_modeToIntializeCam : int):
	APPSTATE.camMode = _modeToIntializeCam
	
	matFishEye = ppe_fishEye_DroneSky.material
	mat_limit_sky.set_shader_parameter("DangerToClose",false)
	mat_limit_fly.set_shader_parameter("DangerToClose",false)

	
	for terrain in Terrains:
		navMeshBounds = navMeshBounds.merge(UTILITIES.get_scene_bounds(terrain))
	
	movSky.Initialize(self)
	movFly.Initialize(self)
	
	_ChangeToMode(_modeToIntializeCam)
	
func CheckMapBoundings(_pivot:Node3D) -> bool:
	var cam_in_world = (_pivot.global_position + (navMeshBounds.size/2))/navMeshBounds.size
	
	positionInMap01 = Vector2(1 - cam_in_world.x, 1 - cam_in_world.z)
	CAM.positionXZ_01 = positionInMap01
	
	var boundingX : float = abs(positionInMap01.x)
	var boundingY : float = abs(positionInMap01.y)
	
	if boundingX >= limitToStartGlich01  || boundingY >= limitToStartGlich01:
		var boundingValue := boundingX if boundingX >= boundingY else boundingY
		CAM.boundings01 = inverse_lerp(limitToStartGlich01,1,boundingValue)
		if CAM.boundings01 < .02:
			CAM.boundings01 = 0
	
	var insideBoundings := boundingX < 1 and boundingY < 1
	return insideBoundings
	
func _input(_event):
	if Input.is_action_just_pressed('3D_ChangeCamMode'):
		camMode = ENUMS.Cam_Mode.fly if APPSTATE.camMode == ENUMS.Cam_Mode.sky else ENUMS.Cam_Mode.sky
		SIGNALS.OnCameraRequestChangeMode.emit(camMode)
		
		await SIGNALS.OnCameraCanChangeMode
		
		APPSTATE.camMode = camMode
		_ChangeToMode(APPSTATE.camMode)

func _process(_delta):
	_UpdateCamState()
	_CheckProximityToLimits()
	
	if valuesInRuntime:
		if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
			movSky.UpdateCamConfig()
		else:
			movFly.UpdateCamConfig()

func _CheckProximityToLimits():
		if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
			_SetShaLimit(mat_limit_sky)
		else:
			_SetShaLimit(mat_limit_fly)

func _SetShaLimit(_mat : ShaderMaterial):
	if CAM.boundings01 > 0 and not dangerToCloseLimit:
		dangerToCloseLimit = true
		_mat.set_shader_parameter("DangerToClose",dangerToCloseLimit)
	elif CAM.boundings01 == 0 and dangerToCloseLimit:
		dangerToCloseLimit = false
		_mat.set_shader_parameter("DangerToClose",dangerToCloseLimit)
		
	print(CAM.boundings01 == 0 and dangerToCloseLimit)

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
		CAM.speed = floori(lerpf(0,fly_UI_maxSpeed, movFly.mov_speed01))
		
func _ChangeToMode(_mode : int):
	if _mode == ENUMS.Cam_Mode.sky:
		_ChangeToMode_Sky()
	else:
		_ChangeToMode_Fly()
		
	SIGNALS.OnCameraChangedMode.emit(_mode)
		
func _ChangeToMode_Sky():
		# World env
		worldEnv.environment = preset_env_sky
		
		#DOF
		worldEnv.camera_attributes = preset_cam_sky
		
		#Light
		UTILITIES.TurnOnObject(ligtht_sun_sky)
		UTILITIES.TurnOffObject(ligtht_sun_fly)
		
		# UI + PPE
		for child in ui_ppe_fly.get_children():
			UTILITIES.TurnOffObject(child)
		for child in ui_ppe_sky.get_children():
			UTILITIES.TurnOnObject(child)
			
		#Roads
		msh_roads.material_override = mat_roads_sky
		
		#Msh limit
		msh_limit.material_override = mat_limit_sky
	
		#Turn on sky cam
		movSky.process_mode = Node.PROCESS_MODE_ALWAYS
		UTILITIES.TurnOnObject(sky_pivot)
		
		#Turn off fly cam
		movFly.process_mode = Node.PROCESS_MODE_DISABLED
		UTILITIES.TurnOffObject(fly_pivot)
		
		#Apply initial values
		movSky.SetCamera()
		
		
func _ChangeToMode_Fly():
		# World env
		worldEnv.environment = preset_env_fly
		
		#DOF
		worldEnv.camera_attributes = preset_cam_fly
		
		#Light
		UTILITIES.TurnOffObject(ligtht_sun_sky)
		UTILITIES.TurnOnObject(ligtht_sun_fly)
		
		# UI + PPE
		for child in ui_ppe_fly.get_children():
			UTILITIES.TurnOnObject(child)
		for child in ui_ppe_sky.get_children():
			UTILITIES.TurnOffObject(child)
			
		#Roads
		msh_roads.material_override = mat_roads_fly
	
		#Msh limit
		msh_limit.material_override = mat_limit_fly
		
		#Turn off sky cam
		movSky.process_mode = Node.PROCESS_MODE_DISABLED
		UTILITIES.TurnOffObject(sky_pivot)
		
		#Turn on fly cam
		movFly.process_mode = Node.PROCESS_MODE_ALWAYS
		UTILITIES.TurnOnObject(fly_pivot)
		
		#Apply initial values
		movFly.SetCamera()
