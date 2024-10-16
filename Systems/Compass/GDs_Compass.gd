extends Node

var pivotCam : Node3D
@export var camManager : GDs_Cam_Manager
@export var PinPos : Node3D
@export var minDistance : float
@export var maxDistance : float
@export var site_color : Color
var CompassLenght : float = 220

var compassInitialXPosition := 0.0
var pinSiteInitialXPosition := 0.0

var postarget2d : Vector2
var Camera : Camera3D
var distance : float
var screenSize : Vector2
var maxMark_TopDown_PosX : float
var maxMark_TopDown_PosY : float

@onready var pin_sitio: ColorRect = $CompassParent/CompassMask/PinSite
@onready var compass: TextureRect = $CompassParent/CompassMask/Compass
@onready var compass_parent: Control = $CompassParent
@onready var top_down_mark: ColorRect = $CompassTopDown/TopDownMark
@onready var compass_top_down: Control = $CompassTopDown
@onready var distance_text: Label = $CompassParent/DistanceBackground/DistanceText

var canRotate : bool

func Initialize(_camManager : GDs_Cam_Manager)-> void:
	pivotCam = _camManager.pivot_cam
	compassInitialXPosition = compass.position.x
	pinSiteInitialXPosition = pin_sitio.position.x
	SIGNALS.OnCameraUpdate.connect(_OnCanRotate)
	
	screenSize = get_viewport().get_visible_rect().size
	maxMark_TopDown_PosX = screenSize.x - top_down_mark.size.x
	maxMark_TopDown_PosY = screenSize.y - top_down_mark.size.y
	
	Camera = camManager.cam
	
	canRotate = true
	
	pin_sitio.color = site_color
	top_down_mark.color = site_color

func _ready() -> void:
	Initialize(camManager)
	
func _OnCanRotate(can : bool)-> void:
	canRotate = can
	
func _ToggleCompass(visible : bool) -> void:
	compass_parent.visible = visible
	compass_top_down.visible = !visible
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	#calculate distance between pivot and mark
	distance = pivotCam.global_position.distance_to(Vector3(PinPos.global_position.x, 0, PinPos.global_position.z))
	
	if APPSTATE.camMode == ENUMS.Cam_Mode.Top:
		_ToggleCompass(false)
		_CalculateTopDownPoint(distance)
	else:
		_ToggleCompass(true)
		_CalculateCompassPoints(distance)
	
func _CalculateCompassPoints(_distance : float) -> void:
	_distance = floorf(_distance)
	distance_text.text = String.num(_distance, 1)
	
	#if canRotate:
		#calculate degrees of pivot cam
	var rotationDegrees = (abs(pivotCam.rotation.y) * 180)/3.1333
	var compassPosition = rotationDegrees * (compass.size.x/6)/180

	#check if look to left or right
	var rotationDir := 1
	if pivotCam.rotation.y < 0:
		rotationDir = -1

	#update compass direction
	compass.position.x = (compassPosition * rotationDir) + compassInitialXPosition

	#calculate dot product between pivot cam and mark
	var pivotCamNormal := pivotCam.global_basis.z
	var MarkNormal := (PinPos.global_position - pivotCam.global_position).normalized()
	var dot := MarkNormal.dot(pivotCamNormal)
	var OffsetMark = abs(dot - 1) * (CompassLenght/2)
	
	#check if look to left or right
	var RightVectorNormal := pivotCam.global_basis.x
	var RightDot := RightVectorNormal.dot(MarkNormal)

	if RightDot > 0:
		OffsetMark *= -1
	
	#update pin mark in compass
	pin_sitio.position.x = OffsetMark + pinSiteInitialXPosition

func _CalculateTopDownPoint(_distance : float) -> void:
	#calculate the position in screen of top down mark
	var targetUnprojectPos :Vector3 = PinPos.global_position
	targetUnprojectPos.y = 0
	postarget2d = Camera.unproject_position(PinPos.global_position)
	
	postarget2d.x = clampf(postarget2d.x,0,maxMark_TopDown_PosX)
	postarget2d.y = clampf(postarget2d.y,0,maxMark_TopDown_PosY)
	
	top_down_mark.global_position = postarget2d
	
