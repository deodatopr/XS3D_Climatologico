class_name GDs_Compass
extends Node

@export var estacion_index : int = 0
@export var local_estaciones : GDs_CR_LocalEstaciones

@export_group("Compass North")
@export var compass_mask:Control
@export var pin_sitio: Control
@export var compass: Control
@export var lblDistance : Label

@export_group("Compass Screen")
@export var screenMark: Control 
@export var pointSitio: Control 
@export var direction : Control
@export var frameColor : Control

var pivotCam : Node3D
var camManager : GDs_Cam_Manager

var compassInitialXPosition := 0.0
var pinSiteInitialXPosition := 0.0

var posSitio : Vector3
var postarget2d : Vector2
var cam : Camera3D
var distance : float
var screenSize : Vector2

var offsetBorder : float = 30

var minPos_X : float
var maxPos_X : float

var minPos_Y : float
var maxPos_Y : float

func Initialize(_camManager : GDs_Cam_Manager, _posWorldSitio3d : Vector3)-> void:
	camManager = _camManager
	pivotCam = _camManager.fly_pivot
	cam = camManager.fly_cam
	posSitio = _posWorldSitio3d
	
	compassInitialXPosition = compass.position.x
	pinSiteInitialXPosition = pin_sitio.position.x
	
	screenSize = get_viewport().get_visible_rect().size
	
	minPos_X = offsetBorder
	maxPos_X = screenSize.x - screenMark.size.x  - offsetBorder
	
	var sizeMenuBottom : float = 105
	minPos_Y = offsetBorder
	maxPos_Y = screenSize.y - screenMark.size.y  - offsetBorder - sizeMenuBottom
	
	#pin_sitio.self_modulate = local_estaciones.LocalEstaciones[estacion_index].color
	screenMark.self_modulate = local_estaciones.LocalEstaciones[estacion_index].color
	screenMark.self_modulate.a = .5
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	
	_CalculateScreenMark()
	_CalculateCompassNorth()

func _CalculateScreenMark() -> void:
	#Position
	
	#Calculate if is in front or back to fix finalPosition
	var dirToSitio : Vector3 = (posSitio - pivotCam.global_position).normalized()
	var dotToSitio : float = pivotCam.global_basis.z.normalized().dot(dirToSitio)
	var dotSign : float = signf(dotToSitio)

	#Calculate the position in screen of top down mark
	postarget2d = cam.unproject_position(posSitio)
	
	#Fix position 2d
	postarget2d *= signf(dotToSitio)	
	if dotSign < 0:
		postarget2d.y = maxPos_Y
	
	#Pos 2d with limits
	postarget2d.x = clampf(postarget2d.x,minPos_X,maxPos_X)
	postarget2d.y = clampf(postarget2d.y,minPos_Y,maxPos_Y)
	
	#Apply
	screenMark.global_position = postarget2d
	
	#Rotation
	
	var centerScreen : Vector2 = Vector2(screenSize.x * .5, screenSize.y * .5)
	var angleToFixRot : float = 90
	var angleRotation : float = rad_to_deg(centerScreen.angle_to_point(postarget2d)) + angleToFixRot
	pointSitio.rotation_degrees = angleRotation
	
	#centerScreen.y +=
	direction.visible = centerScreen.distance_to(postarget2d) > 400

func _CalculateCompassNorth() -> void:
	lblDistance.text = str(CAM.distToSitio)
	
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
	
	var markNormal := (posSitio - pivotCam.global_position).normalized()
	markNormal.y = 0
	
	var dot := pivotCamNormal.dot(markNormal)
	var degrees = acos(dot/(pivotCamNormal.length() * markNormal.length()))
	degrees = degrees * (180/ PI)
	
	var cross := pivotCamNormal.cross(markNormal)
	var offset = ((-degrees * (compass_mask.size.x/2))/180)
	
	if cross.y < 0:
		offset = -offset
		
	pin_sitio.position.x = pinSiteInitialXPosition + offset
