class_name GDs_Vista_Sky
extends Control

@export_group("SCENE REFERENCES")
@export var pinSitio : Node3D
@export_group("INTERNAL REFERENCES")
@export var minimap : GDs_Minimap
@export var compass : GDs_Compass
@export var map_minimap : Texture2D
@export var lblAltura: Label
@export var lblVelocidad: Label
@export var lblRotacion: Label
@export var lblFov: Label

var cam_manager : GDs_Cam_Manager

func Initialize(_cam_manager : GDs_Cam_Manager):
	cam_manager = _cam_manager
	minimap.Initialize(cam_manager,map_minimap)
	compass.Initialize(cam_manager, pinSitio.position, true)

func _process(_delta: float) -> void:
	@warning_ignore('narrowing_conversion')
	lblAltura.text = UTILITIES.FormatAltura(CAM.height)
	@warning_ignore('narrowing_conversion')
	lblVelocidad.text = UTILITIES.FormatVelocidad(CAM.speed)
	lblRotacion.text = UTILITIES.FormatRotacionY(CAM.rotation.y)
	lblFov.text = UTILITIES.FormatFov(CAM.fov)
