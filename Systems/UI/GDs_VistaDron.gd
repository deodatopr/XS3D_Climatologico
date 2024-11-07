class_name GDs_VistaFree
extends Control

@export_group("SCENE REFERENCES")
@export var pinSitio : Node3D

@export_group("INTERNAL REFERENCES")
@export var compass:GDs_Compass

@export var lblAltura:Label
@export var lblVelocidad:Label
@export var lblRotacion:Label


var cam_manager:GDs_Cam_Manager
var worldMark:Node3D
var map:Node3D

var speed:=1.0
var initialTopLinesPosX: float
var initialBottomLinesPosX: float
var initialLeftLinesPosY: float
var initialRightLinesPosY: float
var fixedRot : Vector2

func Initialize():
	compass.Initialize(cam_manager, pinSitio.position)

func _process(_delta):
	lblAltura.text = UTILITIES.FormatAltura(CAM.height)
	@warning_ignore('narrowing_conversion')
	lblVelocidad.text = UTILITIES.FormatVelocidad(CAM.speed)
	fixedRot = CAM.rotation
	fixedRot.x += 20
	lblRotacion.text = UTILITIES.FormatRotacionXY(fixedRot)
