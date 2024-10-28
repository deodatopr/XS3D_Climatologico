class_name GDs_VistaFree
extends Control

@export_group("Datos")
@export var lblAltura:Label
@export var lblVelocidad:Label
@export var lblRotacion:Label

@export_group("Refs Compass")
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
	compass.PinPos = worldMark
	compass.Initialize(cam_manager)

func _process(_delta):
	lblAltura.text = UTILITIES.FormatAltura(CAM.height)
	@warning_ignore('narrowing_conversion')
	lblVelocidad.text = UTILITIES.FormatVelocidad(CAM.speed)
	lblRotacion.text = UTILITIES.FormatRotacionXY(CAM.rotation)
