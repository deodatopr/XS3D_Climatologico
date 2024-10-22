class_name GDs_Cam_Manager extends Node

@export_group("SCENE REFERENCES")
@export var aerialMovement : GDs_AerialMovement
@export var pivot_cam : Node3D
@export var cam : Node3D

@export_group("AERIAL CAMERA")
@export var valuesInRuntime : bool

@export_subgroup("Movements")
@export var aerial_height : float = 600
@export var aerial_move: float = 2
@export_range(1,5) var aerial_boost: float = 3
@export var aerial_curveAccel : Curve
@export var aerial_curveDecel : Curve

@export_subgroup("Camera")
@export var aerial_camRot_speed : float = .07

# FOV speed
# Fov EL INICIAL ES EL MINIMO Y solo un max
@export_range(30,130) var aerial_zoom_in : float = 30
@export var aerial_zoom_out : float = 130

@export_group("DRON CAMERA")
@export var test : float

signal OnCamChangeMode
func _ready():
	Initialize(ENUMS.Cam_Mode.Bottom)
	
func _process(_delta : float):
	if valuesInRuntime:
		aerialMovement.UpdateCamConfig()

func Initialize(_modeToIntializeCam : int):
	APPSTATE.camMode = _modeToIntializeCam
	aerialMovement.Initialize(self)
