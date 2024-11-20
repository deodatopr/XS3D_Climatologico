class_name GDs_Compass
extends Node

@export_group("Compass North")
@export var compass_mask:Control
@export var pin_sitio: Control
@export var compass: Control
@export var lblDistance : Label

@export_group("Compass Screen")
@export var screenMark: Control 
@export var screenMarkBG: Control 
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

var offsetBorder : float = 30

var minPos_X : float
var maxPos_X : float

var minPos_Y : float
var maxPos_Y : float

var rectLimits : Rect2
	
func Initialize(_camManager : GDs_Cam_Manager, _posWorldSitio3d : Vector3)-> void:
	camManager = _camManager
	pivotCam = _camManager.fly_pivot
	cam = camManager.fly_cam
	posSitio = _posWorldSitio3d
	
	compassInitialXPosition = compass.position.x
	pinSiteInitialXPosition = pin_sitio.position.x
	screenMarkBG.self_modulate = APPSTATE.currntSitio.color
	screenMarkBG.self_modulate.a = .5
	
	pin_sitio.self_modulate =  APPSTATE.currntSitio.color
	
	OnScreenChangeSize()
	
	if not get_viewport().size_changed.is_connected(OnScreenChangeSize):
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
	rectLimits = Rect2(Vector2(minPos_X,minPos_Y), Vector2(maxPos_X - minPos_X, maxPos_Y- minPos_Y))

	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	
	_CalculateScreenMark()
	_CalculateCompassNorth()

func _CalculateScreenMark() -> void:
	#Position -----------

	#Calculate if is in front or back to fix finalPosition	
	var dirToSitio : Vector3 = (posSitio - pivotCam.global_position).normalized()
	var pivotCamForward : Vector3 = -pivotCam.global_basis.z.normalized()
	var dotToSitio : float = pivotCamForward.dot(dirToSitio)
	var dotSign : float = signf(dotToSitio)
	
	#Convert position 3d into 2d
	posTarget2d = cam.unproject_position(posSitio)
	posTarget2d *= dotSign


	#Fix pos when point is out of limit border
	var isInsideSight : bool = rectLimits.has_point(posTarget2d)
	if isInsideSight:
		posTarget2d.x -= screenMark.size.x * 0.5
		posTarget2d.y -= screenMark.size.y * 0.5
	else:
		posTarget2d = GetValidPointOnLimits(rectLimits,aimCenter,aimCenter.direction_to(posTarget2d))
	
	#Fix when site is behind camera (always keep mark in on the bottom border)
	if dotSign < 0:
		posTarget2d.y = maxPos_Y
		
	#Apply
	screenMark.global_position = posTarget2d
	
	#Rotation -----------
	var angleOffsetRot : float = 90
	var angleRotation : float = rad_to_deg(aimCenter.angle_to_point(posTarget2d)) + angleOffsetRot
	pointSitio.rotation_degrees = angleRotation
	
	direction.visible = not isInsideSight


func GetValidPointOnLimits(_rect: Rect2, _center: Vector2, _dir: Vector2) -> Vector2:
	var evaluated_point: Vector2 = _center
	var dir_normalized: Vector2 = _dir.normalized()

	# Calcular distancias hasta los bordes del rectángulo desde el centro
	var dist_x: float = abs((_rect.end.x - _center.x) / dir_normalized.x) if dir_normalized.x != 0 else INF
	var dist_y: float = abs((_rect.end.y - _center.y) / dir_normalized.y) if dir_normalized.y != 0 else INF

	# Tomar la menor distancia, ya que esta es la primera intersección con los límites
	var dist_to_border: float = min(dist_x, dist_y)
	evaluated_point += dir_normalized * dist_to_border

	return evaluated_point

func _CalculateCompassNorth() -> void:
	lblDistance.text = str(CAM.distToSitio)

	#update compass direction
	compass.position.x = compassInitialXPosition + (int(pivotCam.rotation.y * 180) %1128) 

	var pivotCamNormal := -pivotCam.global_basis.z
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
