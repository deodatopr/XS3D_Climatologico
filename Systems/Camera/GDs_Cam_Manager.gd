class_name GDs_Cam_Manager extends Node

@export var valuesInRuntime : bool

@export_group("SCENE REFERENCES")
@export var mshNavigation : Node3D
@export var Terrains: Array [Node3D]
@export var worldEnv : WorldEnvironment
@export var msh_roads : MeshInstance3D
@export var msh_limit : MeshInstance3D
@export var pinSitio : Node3D
@export var ppe_fishEye_DroneSky : ColorRect
@export var ui_ppe_sky : Node
@export var ui_ppe_fly : Node
@export var light_sun_sky : Node3D
@export var light_sun_fly : Node3D

@export_group("INTERNAL REFERENCES")
@export var movSky : GDs_Cam_Mov_Sky
@export var sky_pivot : Node3D
@export var sky_cam : Camera3D
@export var movFly : GDs_Cam_Mov_Fly
@export var fly_pivot : Node3D
@export var fly_cam : Camera3D

@export_group("CAMERAS")
@export var curveMovement : Curve
@export_range(.7, 1.0) var proximityEdgeLimits : float = .9

@export_subgroup("SKY")
@export_custom(PROPERTY_HINT_NONE,"suffix: m") var sky_height : float = 500
@export_custom(PROPERTY_HINT_NONE,"suffix: km/h") var sky_speed: float = 100
@export_custom(PROPERTY_HINT_NONE,"suffix: multiplier") var sky_turbo: float = 2
@export var sky_rot_speed : float = .1
@export_custom(PROPERTY_HINT_NONE,"suffix: fov") var sky_zoom_in : float = 30
@export_custom(PROPERTY_HINT_NONE,"suffix: fov") var sky_zoom_out : float = 100

@export_subgroup("FLY")
@export_range(30,100) var fly_fov :float = 50
@export var fly_height_speed : float = 7
@export_custom(PROPERTY_HINT_NONE,"suffix: m") var fly_height_max : float = 400
@export_custom(PROPERTY_HINT_NONE,"suffix: m") var fly_height_min : float = 200
@export_custom(PROPERTY_HINT_NONE,"suffix: km/h") var fly_speed : float = 80
@export_custom(PROPERTY_HINT_NONE,"suffix: multiplier") var fly_turbo : float = 2.5
@export_range(.1,2,.1) var fly_acce_dece: float = 1
@export_custom(PROPERTY_HINT_NONE,"suffix: °") var fly_rot_clamp : float = 40
@export var fly_rot_speed : float = .5

@onready var mat_limit_sky : ShaderMaterial = preload("uid://b5mdctmpig2lv")
@onready var mat_limit_fly : ShaderMaterial = preload("uid://nan3iase8pij")

@onready var preset_env_sky : Environment = preload('res://Systems/Camera/Presets/Preset_Env_Sky_Sunny.tres')
@onready var preset_env_fly : Environment = preload('res://Systems/Camera/Presets/Preset_Env_Fly_Sunny.tres')

@onready var preset_gym_fly_sunny : Environment = preload('res://#Resources/Gym/Presets/Preset_Gym_Fly_Sunny.tres')
@onready var preset_gym_sky_sunny : Environment = preload('res://#Resources/Gym/Presets/Preset_Gym_Sky_Sunny.tres')

@onready var preset_cam_sky : CameraAttributesPractical = preload("uid://ddf3muiyuuvj6")
@onready var preset_cam_fly : CameraAttributesPractical = preload("uid://b6jeytnq38xvp")

var wasInitialized : bool
var navMesh : NavigationRegion3D
var navigationMesh : NavigationMesh
var navMeshRID : RID #RID = identificador, necesario para usar info del navmesh
var navMeshBounds : AABB
var camMode : int
var last_rotation : float

var sky_UI_maxSpeed : int = 250
var fly_UI_maxSpeed : int = 100

var dangerToCloseLimit : bool
var positionInMap01 : Vector2 = Vector2.ZERO
var matFishEye :  ShaderMaterial
var auxToCalculateDistance : Vector3
var lastCamFlyHeight : float
	
func Initialize(_modeToIntializeCam : int):
	APPSTATE.camMode = _modeToIntializeCam
	
	matFishEye = ppe_fishEye_DroneSky.material
	mat_limit_sky.set_shader_parameter("DangerToClose",false)
	mat_limit_fly.set_shader_parameter("DangerToClose",false)
	navMesh = mshNavigation.get_child(0) as NavigationRegion3D
	
	if not navMeshRID.is_valid():
		navMeshRID = navMesh.get_navigation_map()
	
	for terrain in Terrains:
		navMeshBounds = navMeshBounds.merge(UTILITIES.GetNodeBounds(terrain))
	
	movSky.Initialize(self)
	movFly.Initialize(self)
	
	_ChangeToMode(_modeToIntializeCam)
	
	wasInitialized = true

	
func CheckMapBoundings(_pivot:Node3D) -> bool:
	#Save position 01 in map
	var cam_in_world := (_pivot.global_position + (navMeshBounds.size * .5))/navMeshBounds.size
	positionInMap01 = Vector2(1 - cam_in_world.x, 1 - cam_in_world.z)
	CAM.positionXZ_01 = positionInMap01
	
	#Change positionInMap01 range from -1 to 1 to handle boundings easily
	positionInMap01.x = lerpf(-1,1,positionInMap01.x)
	positionInMap01.y = lerpf(-1,1,positionInMap01.y)
	
	var boundingX : float = abs(positionInMap01.x)
	var boundingY : float = abs(positionInMap01.y)
	
	#Only inside range limits calculate a value to detect proximity to end limit
	if boundingX >= proximityEdgeLimits  || boundingY >= proximityEdgeLimits:
		var boundingValue := boundingX if boundingX >= boundingY else boundingY

		CAM.boundings01 = inverse_lerp(proximityEdgeLimits,1,boundingValue)
		if CAM.boundings01 < .02:
			CAM.boundings01 = 0
			
	var insideBoundings := boundingX < 1 and boundingY < 1
	return insideBoundings
	
func GetPointOnMap(_targetPoint : Vector3) -> Vector3:
	if NavigationServer3D.map_get_iteration_id(navMeshRID) > 0:
		var closest_point := NavigationServer3D.map_get_closest_point(navMeshRID, _targetPoint)
		return closest_point
		
	return Vector3.ZERO
	
func _input(_event):
	if Input.is_action_just_pressed('3D_ChangeCamMode'):
		camMode = ENUMS.Cam_Mode.fly if APPSTATE.camMode == ENUMS.Cam_Mode.sky else ENUMS.Cam_Mode.sky
		SIGNALS.OnCameraRequestChangeMode.emit(camMode)
		
		await SIGNALS.OnCameraCanChangeMode
		
		APPSTATE.camMode = camMode
		_ChangeToMode(APPSTATE.camMode)

func _process(_delta):
	if not wasInitialized:
		return
	
	_UpdateCamState()
	_CheckProximityToLimits()
	
	if valuesInRuntime:
		if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
			movSky.UpdateValuesInRuntime()
		else:
			movFly.UpdateValuesInRuntime()

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

func _UpdateCamState():
	var cam : Camera3D = sky_cam if APPSTATE.camMode == ENUMS.Cam_Mode.sky else fly_cam
	var dir = sign(cam.global_rotation_degrees.y)
	var fixRotY = abs(floori(cam.global_rotation_degrees.y - 180))
	
	if abs(ceili(cam.global_rotation_degrees.y - 180)) == 360:
		CAM.rotation = Vector2(floori(cam.global_rotation_degrees.x), 0)
	elif dir > 0:
		CAM.rotation = Vector2(floori(cam.global_rotation_degrees.x),ceili(fixRotY))
	elif dir < 0:
		CAM.rotation = Vector2(floori(cam.global_rotation_degrees.x),ceili(abs(fixRotY - 360)))
	
	CAM.isHeightChanging = absf(cam.global_position.y - lastCamFlyHeight) > .1
	CAM.height = ceili(cam.global_position.y)
	lastCamFlyHeight = cam.global_position.y
	
	CAM.fov = ceili(cam.fov)
	CAM.position = cam.global_position
	
	last_rotation = cam.global_rotation_degrees.y
	
	if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
		CAM.speed = roundi(movSky.mov_speedForUI)
	else:
		if movFly.mov_velocity.length() > 0.0:
			CAM.speed = roundi(movFly.mov_speedForUI)
		else:
			CAM.speed = roundi(movFly.mov_height_speedForUI)
		
	auxToCalculateDistance = cam.global_position
	auxToCalculateDistance.y = pinSitio.global_position.y
	CAM.distToSitio = floori(auxToCalculateDistance.distance_to(pinSitio.global_position))
		
func _ChangeToMode(_mode : int):
	if _mode == ENUMS.Cam_Mode.sky:
		_ChangeToMode_Sky()
	else:
		_ChangeToMode_Fly()
		
	SIGNALS.OnCameraChangedMode.emit(_mode)
		
func _ChangeToMode_Sky():
	if DEBUG.lLuvia == ENUMS.LluviaIntsdad.SinLluvia:
		# World env
		if DEBUG.isGym:
			worldEnv.environment = preset_gym_sky_sunny
		else:
			worldEnv.environment = preset_env_sky
		
		#DOF
		worldEnv.camera_attributes = preset_cam_sky
		#Light
		UTILITIES.TurnOnObject(light_sun_sky)
		UTILITIES.TurnOffObject(light_sun_fly)
		
		# UI + PPE
	for child in ui_ppe_fly.get_children():
		UTILITIES.TurnOffObject(child)
	for child in ui_ppe_sky.get_children():
		UTILITIES.TurnOnObject(child)
		
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
	if DEBUG.lLuvia == ENUMS.LluviaIntsdad.SinLluvia:
		# World env
		if DEBUG.isGym:
			worldEnv.environment = preset_gym_fly_sunny
		else:
			worldEnv.environment = preset_env_fly
		
		#DOF
		worldEnv.camera_attributes = preset_cam_fly
		#Light
		UTILITIES.TurnOffObject(light_sun_sky)
		UTILITIES.TurnOnObject(light_sun_fly)
		
		# UI + PPE
	for child in ui_ppe_fly.get_children():
		UTILITIES.TurnOnObject(child)
	for child in ui_ppe_sky.get_children():
		UTILITIES.TurnOffObject(child)
	
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
