class_name GDs_Cam_Manager extends Node

@export_group("SCENE REFERENCES")
@export var movAerial : GDs_Cam_Mov_Aerial
@export var movDron : GDs_Cam_Mov_Dron
@export var pivot_cam : Node3D
@export var cam : Node3D
@export var curveAccel : Curve
@export var curveDecel : Curve
@export var debug_skipCurtainToChangeMode : bool = true

@export_group("AERIAL CAMERA")
@export var valuesInRuntime : bool

@export_subgroup("Movements")
@export var aerial_height : float = 600
@export var aerial_move: float = 2
@export_range(1,5) var aerial_boost: float = 3

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
@export var dron_vert_max : float = 90
@export var dron_vert_min : float = -90
@export var dron_vert_return : float = 1

var currentCamMode : int

func _ready():
	currentCamMode = ENUMS.Cam_Mode.Dron
	Initialize(currentCamMode)
	
func _input(event):
	if Input.is_action_pressed('3DMove_ChangeCamMode'):
		if not debug_skipCurtainToChangeMode:
			SIGNALS.OnCameraRequestChangeMode.emit()
			
			await SIGNALS.OnCameraCanChangeMode
		
		APPSTATE.camMode = ENUMS.Cam_Mode.Dron if APPSTATE.camMode == ENUMS.Cam_Mode.Aerial else ENUMS.Cam_Mode.Aerial
		ChangeToMode(APPSTATE.camMode)
	
func _process(_delta : float):
	if valuesInRuntime:
		movAerial.UpdateCamConfig()

func Initialize(_modeToIntializeCam : int):
	APPSTATE.camMode = _modeToIntializeCam
	movAerial.Initialize(self)
	movDron.Initialize(self)
	
	ChangeToMode(_modeToIntializeCam)
	
func ChangeToMode(_mode : int):
	if _mode == ENUMS.Cam_Mode.Aerial:
		movAerial.process_mode = Node.PROCESS_MODE_ALWAYS
		movDron.process_mode = Node.PROCESS_MODE_DISABLED
		
		movAerial.SetCamera()
	else:
		movAerial.process_mode = Node.PROCESS_MODE_DISABLED
		movDron.process_mode = Node.PROCESS_MODE_ALWAYS
		
		movDron.SetCamera()
