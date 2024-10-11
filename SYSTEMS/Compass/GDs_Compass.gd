extends Node

var pivotCam : Node3D
@export var camManager : GDs_Cam_Manager
@export var MarkRef : Node3D
@export var minDistance : float
@export var maxDistance : float
var CompassLenght : float = 220

var compassInitialXPosition := 0.0
var pinSiteInitialXPosition := 0.0

var postarget2d : Vector2
var Camera : Camera3D
var centerScreen : Vector2
var dir : Vector2

@onready var pin_sitio: Panel = $CompassParent/CompassMask/PinSite
@onready var compass: TextureRect = $CompassParent/CompassMask/Compass
@onready var compass_parent: Control = $CompassParent
@onready var top_down_mark: ColorRect = $CompassTopDown/TopDownMark
@onready var compass_top_down: Control = $CompassTopDown

var canRotate : bool

func Initialize(_camManager : GDs_Cam_Manager)-> void:
	pivotCam = _camManager.pivot_cam
	compassInitialXPosition = compass.position.x
	pinSiteInitialXPosition = pin_sitio.position.x
	SIGNALS.OnCameraUpdate.connect(_OnCanRotate)
	
	Camera = camManager.cam
	
	canRotate = true

func _ready() -> void:
	Initialize(camManager)
	
func _OnCanRotate(can : bool)-> void:
	canRotate = can
	
func _ToggleCompass(visible : bool) -> void:
	compass_parent.visible = visible
	compass_top_down.visible = !visible
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	if APPSTATE.camHeight01 == 1:
		_ToggleCompass(false)
		_CalculateTopDownPoint()
	else:
		_ToggleCompass(true)
		_CalculateCompassPoints()
	
func _CalculateCompassPoints() -> void:
	if canRotate:
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
		var pivotCamNormal := pivotCam.transform.basis.z
		var MarkNormal := (MarkRef.position - pivotCam.position).normalized()
		var dot := pivotCamNormal.dot(MarkNormal)
		var OffsetMark = abs(dot - 1) * (CompassLenght/2)
		
		#check if look to left or right
		var RightVectorNormal := pivotCam.transform.basis.x
		var RightDot := RightVectorNormal.dot(MarkNormal)

		if RightDot > 0:
			OffsetMark *= -1
		
		#update pin mark in compass
		pin_sitio.position.x = OffsetMark + pinSiteInitialXPosition

func _CalculateTopDownPoint() -> void:
	#calculate distance between pivot and mark
	var distance := pivotCam.global_position.distance_to(MarkRef.global_position)
	
	#check if is enough near to hide or show
	if distance < minDistance and compass_top_down.visible:
		compass_top_down.visible = false
	elif distance > minDistance and !compass_top_down.visible:
		compass_top_down.visible = true
	
	#calculate the position in screen of top down mark
	postarget2d = Camera.unproject_position(MarkRef.global_position)
	centerScreen = get_viewport().get_visible_rect().size/2
	dir = postarget2d - centerScreen
	dir = dir.normalized()
	var nearMark := (clampf(distance, minDistance, maxDistance)*.87)/maxDistance
	if top_down_mark.global_position.x < 0:
		nearMark -= .23
	
	#update top down mark position in screen
	top_down_mark.global_position = centerScreen + Vector2(dir.x * (centerScreen.x * nearMark), dir.y * (centerScreen.y * nearMark))
	
