class_name GDs_Cam_Manager extends Node

@export_group("SCENE REFERENCES")
@export var movAerial : GDs_Cam_Mov_Aerial
@export var movDron : GDs_Cam_Mov_Dron
@export var curveAccel : Curve
@export var curveDecel : Curve

@export_group("INTERNAL REFERENCES")
@export var aerial_pivot : Node3D
@export var aerial_cam : Camera3D
@export var dron_pivot : Node3D
@export var dron_cam : Camera3D

@export_group("AERIAL CAMERA")
@export var valuesInRuntime : bool

@export_subgroup("Movements")
@export var aerial_height : float = 600
@export var aerial_move: float = 2
@export_range(1,2) var aerial_boost: float = 1.5

@export_subgroup("Camera")
@export var aerial_camRot_speed : float = .07

@export_range(30,130) var aerial_zoom_in : float = 30
@export var aerial_zoom_out : float = 130

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

var camMode : int

var aerial_UI_maxSpeed : int = 250

var dron_UI_maxSpeed : int = 100

var last_rotation : float

func _ready():
	var rndMode : RandomNumberGenerator = RandomNumberGenerator.new()
	var rndNumber : int = rndMode.randi_range(0,100)
	camMode = ENUMS.Cam_Mode.Dron if rndNumber % 2 == 0 else ENUMS.Cam_Mode.Aerial
	Initialize(camMode)
	
func Initialize(_modeToIntializeCam : int):
	APPSTATE.camMode = _modeToIntializeCam
	movAerial.Initialize(self)
	movDron.Initialize(self)
	
	ChangeToMode(_modeToIntializeCam)
	
func _input(_event):
	if Input.is_action_just_pressed('3DMove_ChangeCamMode'):
		camMode = ENUMS.Cam_Mode.Dron if APPSTATE.camMode == ENUMS.Cam_Mode.Aerial else ENUMS.Cam_Mode.Aerial
		SIGNALS.OnCameraRequestChangeMode.emit(camMode)
		
		await SIGNALS.OnCameraCanChangeMode
		
		APPSTATE.camMode = camMode
		ChangeToMode(APPSTATE.camMode)

func _process(_delta):
	UpdateCamState()
	if valuesInRuntime:
		if APPSTATE.camMode == ENUMS.Cam_Mode.Aerial:
			movAerial.UpdateCamConfig()
		else:
			movDron.UpdateCamConfig()
	
func UpdateCamState():
	var cam : Camera3D = aerial_cam if APPSTATE.camMode == ENUMS.Cam_Mode.Aerial else dron_cam 
	var pivot : Node3D = aerial_pivot if APPSTATE.camMode == ENUMS.Cam_Mode.Aerial else dron_pivot 
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
	
	if APPSTATE.camMode == ENUMS.Cam_Mode.Aerial:
		CAM.speed = floori(lerpf(0,aerial_UI_maxSpeed, movAerial.speed01))
	else:
		CAM.speed = floori(lerpf(0,dron_UI_maxSpeed, movDron.speed01))
		
func ChangeToMode(_mode : int):
	if _mode == ENUMS.Cam_Mode.Aerial:
		movAerial.process_mode = Node.PROCESS_MODE_ALWAYS
		UTILITIES.TurnOnObject(aerial_pivot)
		
		movDron.process_mode = Node.PROCESS_MODE_DISABLED
		UTILITIES.TurnOffObject(dron_pivot)
		
		movAerial.SetCamera()
	else:
		movAerial.process_mode = Node.PROCESS_MODE_DISABLED
		UTILITIES.TurnOffObject(aerial_pivot)
		
		movDron.process_mode = Node.PROCESS_MODE_ALWAYS
		UTILITIES.TurnOnObject(dron_pivot)
		
		movDron.SetCamera()
