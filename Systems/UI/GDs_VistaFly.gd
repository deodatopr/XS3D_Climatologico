class_name GDs_VistaFly extends Control

@export_group("SCENE REFERENCES")
@export var pinSitio : Node3D

@export_group("INTERNAL REFERENCES")
@export var compass:GDs_Compass

@export var lblAltura:Label
@export var lblVelocidad:Label
@export var lblRotacion:Label

var cam_manager:GDs_Cam_Manager
var fixedRot : Vector2

func Initialize(_cam_manager:GDs_Cam_Manager):
	cam_manager = _cam_manager
	compass.Initialize(cam_manager, pinSitio.position)

func _process(_delta):
	lblAltura.text = UTILITIES.FormatAltura(CAM.height)
	@warning_ignore('narrowing_conversion')
	lblVelocidad.text = UTILITIES.FormatVelocidad(CAM.speed)
	fixedRot = CAM.rotation
	fixedRot.x += 20
	lblRotacion.text = UTILITIES.FormatRotacionXY(fixedRot)
