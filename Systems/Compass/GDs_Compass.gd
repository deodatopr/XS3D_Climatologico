class_name GDs_Compass
extends Node

@export var testDirection : Control
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
var posTarget2d : Vector2
var cam : Camera3D
var distance : float
var screenSize : Vector2
var aimCenter : Vector2
var lastPosition : Vector2

var offsetBorder : float = 30

var minPos_X : float
var maxPos_X : float

var minPos_Y : float
var maxPos_Y : float

func _ready():
	get_viewport().size_changed.connect(OnScreenChangeSize)
	
func OnScreenChangeSize():
	#Screen size calculate here to avoid errors if it is maximized or minimized in runtime
	screenSize = get_viewport().get_visible_rect().size	
	minPos_X = offsetBorder
	maxPos_X = screenSize.x - screenMark.size.x  - offsetBorder
	
	var sizeMenuBottom : float = 105
	minPos_Y = offsetBorder
	maxPos_Y = screenSize.y - screenMark.size.y  - offsetBorder - sizeMenuBottom
	
	aimCenter = Vector2((minPos_X + maxPos_X) *.5, (minPos_Y + maxPos_Y) * .5)

func Initialize(_camManager : GDs_Cam_Manager, _posWorldSitio3d : Vector3)-> void:
	camManager = _camManager
	pivotCam = _camManager.fly_pivot
	cam = camManager.fly_cam
	posSitio = _posWorldSitio3d
	
	compassInitialXPosition = compass.position.x
	pinSiteInitialXPosition = pin_sitio.position.x
	
	#pin_sitio.self_modulate = local_estaciones.LocalEstaciones[estacion_index].color
	screenMark.self_modulate = local_estaciones.LocalEstaciones[estacion_index].color
	screenMark.self_modulate.a = .5
	
	OnScreenChangeSize()
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	
	_CalculateScreenMark(delta)
	_CalculateCompassNorth()

func _CalculateScreenMark(delta: float) -> void:
	#Position -----------

	#Calculate if is in front or back to fix finalPosition	
	var dirToSitio : Vector3 = (posSitio - pivotCam.global_position).normalized()
	var dotToSitio : float = pivotCam.global_basis.z.normalized().dot(dirToSitio)
	var dotSign : float = signf(dotToSitio)
	
	#posTarget2d = cam.unproject_position(posSitio)
	#posTarget2d *= dotSign
	#if dotToSitio < 0:
		#posTarget2d.y = maxPos_Y
		
	#Convert position 3d into 2d
	if dotToSitio >= 0:
		posTarget2d = cam.unproject_position(posSitio)
	else:
		posTarget2d = cam.unproject_position(posSitio)
		var dirFromAim : Vector2 = aimCenter.direction_to(posTarget2d)
		dirFromAim.x = -dirFromAim.x
		dirFromAim.y = -dirFromAim.y
		posTarget2d = aimCenter + (dirFromAim * 1000)

	#testDirection.global_position = aimCenter + (aimCenter.direction_to(posTarget2d) * 100)
	
	#Pos 2d with limits
	posTarget2d.x = clampf(posTarget2d.x,minPos_X,maxPos_X)
	posTarget2d.y = clampf(posTarget2d.y,minPos_Y,maxPos_Y)
	
	#Apply
	screenMark.global_position = posTarget2d
	
	#Rotation -----------
	var angleOffsetRot : float = 90
	var angleRotation : float = rad_to_deg(aimCenter.angle_to_point(posTarget2d)) + angleOffsetRot
	pointSitio.rotation_degrees = angleRotation
	
	direction.visible = aimCenter.distance_to(posTarget2d) > aimCenter.y * .5

func _CalculateCompassNorth() -> void:
	lblDistance.text = str(CAM.distToSitio)
	
	#calculate degrees of pivot cam
	var rotationDegrees = (abs(pivotCam.rotation.y) * 180)/3.1333
	@warning_ignore('unused_variable')
	var compassPosition = rotationDegrees * (compass.size.x/6)/180

	#check if look to left or right
	@warning_ignore('unused_variable')
	var rotationDir := 1
	if pivotCam.rotation.y < 0:
		rotationDir = -1

	#update compass direction
	#compass.position.x = (compassPosition * rotationDir) + compassInitialXPosition
	compass.position.x = compassInitialXPosition + (int(pivotCam.rotation.y * 180) %1128) 

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
