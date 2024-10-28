class_name GDs_Vista_Drone
extends Control

@export_group("Datos")
@export var lblVelocidad: Label
@export var lblRotacion: Label
@export var lblFov: Label

@export_group("External Ref")
@export var cam_manager : GDs_Cam_Manager


func _process(delta: float) -> void:
	lblVelocidad.text = UTILITIES.FormatVelocidad(CAM.speed)
	lblRotacion.text = UTILITIES.FormatRotacionY(CAM.rotation.y)
	lblFov.text = UTILITIES.FormatFov(CAM.fov)
