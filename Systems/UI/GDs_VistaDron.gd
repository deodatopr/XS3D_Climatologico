class_name GDs_VistaDron
extends Control

@export_group("Datos")
@export var lblAltura:Label
@export var lblVelocidad:Label
@export var lblRotacion:Label
@export_group("Lineas")
@export var topLines:Control
@export var bottomLines:Control
@export var LeftLines:Control
@export var RightLines:Control

@export_group("Refs Minimap")
@export var minimap:GDs_Minimap
@export var compass:GDs_Compass
var cam_manager:GDs_Cam_Manager
var worldMark:Node3D
var map:Node3D


var speed:=1.0
var initialTopLinesPosX: float
var initialBottomLinesPosX: float
var initialLeftLinesPosY: float
var initialRightLinesPosY: float


func Initialize():
	pass
	#initialTopLinesPosX = topLines.position.x
	#initialBottomLinesPosX = bottomLines.position.x
	#initialLeftLinesPosY = LeftLines.position.y
	#initialRightLinesPosY = RightLines.position.y
	
	#minimap.cam_Manager = cam_manager
	#minimap.mark_target = worldMark
	#minimap.map = map
	#minimap.Initialize()
	#
	#compass.PinPos = worldMark
	#compass.Initialize(cam_manager)

func _process(_delta):
	lblAltura.text = UTILITIES.FormatAltura(CAM.height)
	@warning_ignore('narrowing_conversion')
	lblVelocidad.text = UTILITIES.FormatVelocidad(CAM.speed)
	lblRotacion.text = UTILITIES.FormatRotacionXY(CAM.rotation)

#func _physics_process(_delta):
	#TODO agregar posicion de camara a las lineas horizontales 
	#topLines.position.x = initialTopLinesPosX +(CAM.rotation.y * 3) 
	#bottomLines.position.x = initialBottomLinesPosX +(CAM.rotation.y * 3) 
	#
	#LeftLines.position.y = initialLeftLinesPosY + (CAM.rotation.x * 2) + CAM.height
	#RightLines.position.y = initialRightLinesPosY + (CAM.rotation.x * 2) + CAM.height
	
