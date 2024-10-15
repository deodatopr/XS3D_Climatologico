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
var distance : float

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
	#calculate distance between pivot and mark
	distance = pivotCam.global_position.distance_to(MarkRef.global_position)
	
	if APPSTATE.camMode == ENUMS.Cam_Mode.Top:
		_ToggleCompass(false)
		_CalculateTopDownPoint(distance)
	else:
		_ToggleCompass(true)
		_CalculateCompassPoints(distance)
	
func _CalculateCompassPoints(_distance : float) -> void:
	
	distance_text.text = String.num(_distance, 0)

	#check if is enough near to hide or show. min distance need a value higher to not hide the pin very near of site and add value to not create a separete var
	if _distance < minDistance + 15 and pin_sitio.visible:
		pin_sitio.visible = false
	elif _distance > minDistance + 15 and !pin_sitio.visible:
		pin_sitio.visible = true
	
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
		var pivotCamNormal := pivotCam.global_basis.z
		var MarkNormal := (MarkRef.global_position - pivotCam.global_position).normalized()
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
	
	#check if is enough near to hide or show
	if _distance < minDistance and compass_top_down.visible:
		compass_top_down.visible = false
	elif _distance > minDistance and !compass_top_down.visible:
		compass_top_down.visible = true
	
	#calculate the position in screen of top down mark
	postarget2d = Camera.unproject_position(MarkRef.global_position)
	centerScreen = get_viewport().get_visible_rect().size/2
	dir = postarget2d - centerScreen
	dir = dir.normalized()
	#value 1.6 is a coeficient wthat define the value from center of screen to edge to adjust the mark to screen 
	var nearMark := (clampf(_distance, minDistance, maxDistance)*1.6)/maxDistance
	
	#update top down mark position in screen
	var screenSize := get_viewport().get_visible_rect().size/2
	top_down_mark.global_position = centerScreen + Vector2(clamp(dir.x * (centerScreen.x * nearMark), -screenSize.x, screenSize.x - top_down_mark.size.x), clamp(dir.y * (centerScreen.y * nearMark), -screenSize.y, screenSize.y - top_down_mark.size.y))
	
