class_name GDs_Compass
extends Node

var pivotCam : Node3D
var camManager : GDs_Cam_Manager
@export var PinPos : Node3D
@export var minDistance : float
@export var maxDistance : float
@export var estacion_index : int = 0

var compassInitialXPosition := 0.0
var pinSiteInitialXPosition := 0.0

var postarget2d : Vector2
var Camera : Camera3D
var distance : float
var screenSize : Vector2
var maxMark_TopDown_PosX : float
var maxMark_TopDown_PosY : float

@onready var pin_sitio: TextureRect = $CompassParent/CompassMask/PinSite
@onready var compass: NinePatchRect = $CompassParent/CompassMask/Compass
@onready var compass_parent: Control = $CompassParent
@onready var top_down_mark: ColorRect = $CompassTopDown/TopDownMark
@onready var compass_top_down: Control = $CompassTopDown
@onready var distance_text: Label = $CompassParent/DistanceBackground/DistanceText
@onready var compass_mask = $CompassParent/CompassMask
@onready var distance_top_down = $CompassTopDown/TopDownMark/DistanceTopDown

@onready var local_estaciones : GDs_CR_LocalEstaciones = preload("uid://3nj42mys6ryu")

var canRotate : bool

func Initialize(_camManager : GDs_Cam_Manager)-> void:
	camManager = _camManager
	pivotCam = _camManager.pivot_cam
	compassInitialXPosition = compass.position.x
	pinSiteInitialXPosition = pin_sitio.position.x
	SIGNALS.OnCameraUpdate.connect(_OnCanRotate)
	
	screenSize = get_viewport().get_visible_rect().size
	maxMark_TopDown_PosX = screenSize.x - top_down_mark.size.x
	maxMark_TopDown_PosY = screenSize.y - top_down_mark.size.y - distance_top_down.size.y
	
	Camera = camManager.cam
	
	canRotate = true
	
	pin_sitio.self_modulate = local_estaciones.LocalEstaciones[estacion_index].color
	top_down_mark.color = local_estaciones.LocalEstaciones[estacion_index].color

	
func _OnCanRotate(can : bool)-> void:
	canRotate = can
	
func _ToggleCompass(visible : bool) -> void:
	compass_top_down.visible = !visible

	var compass_animation : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if !visible:
		compass_animation.tween_property(compass_parent, "modulate", Color(1, 1, 1, 0), .15)
	else:
		compass_animation.tween_property(compass_parent, "modulate", Color(1, 1, 1, 1), .15)


@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	#calculate distance between pivot and mark
	if canRotate:
		distance = pivotCam.global_position.distance_to(Vector3(PinPos.global_position.x, 0, PinPos.global_position.z))
		
		if APPSTATE.camMode == ENUMS.Cam_Mode.Dron:
			_ToggleCompass(true)
			_CalculateTopDownPoint(distance)
		else:
			_ToggleCompass(false)
			_CalculateCompassPoints(distance)
	
func _CalculateCompassPoints(_distance : float) -> void:
	_distance = floorf(_distance)
	distance_text.text = String.num(_distance, 1)
	
	#calculate degrees of pivot cam
	var rotationDegrees = (abs(pivotCam.rotation.y) * 180)/3.1333
	var compassPosition = rotationDegrees * (compass.size.x/6)/180

	#check if look to left or right
	var rotationDir := 1
	if pivotCam.rotation.y < 0:
		rotationDir = -1

	#update compass direction
	compass.position.x = (compassPosition * rotationDir) + compassInitialXPosition

	var pivotCamNormal := pivotCam.global_basis.z
	pivotCamNormal.y = 0;
	var MarkNormal := (PinPos.global_position - pivotCam.global_position).normalized()
	MarkNormal.y = 0
	var dot := pivotCamNormal.dot(MarkNormal)
	var degrees = acos(dot/(pivotCamNormal.length() * MarkNormal.length()))
	degrees = degrees * (180/ PI)
	var cross := pivotCamNormal.cross(MarkNormal)
	var offset = ((-degrees * (compass_mask.size.x/2))/180)
	
	if cross.y < 0:
		offset = -offset
		
	pin_sitio.position.x = pinSiteInitialXPosition + offset
	
func _CalculateTopDownPoint(_distance : float) -> void:
	_distance = floorf(_distance)
	distance_top_down.text = String.num(_distance, 1)
	#calculate the position in screen of top down mark
	var targetUnprojectPos :Vector3 = PinPos.global_position
	targetUnprojectPos.y = 0
	postarget2d = Camera.unproject_position(PinPos.global_position)
	
	postarget2d.x = clampf(postarget2d.x,0,maxMark_TopDown_PosX)
	postarget2d.y = clampf(postarget2d.y,0,maxMark_TopDown_PosY)
	
	top_down_mark.global_position = postarget2d
	
