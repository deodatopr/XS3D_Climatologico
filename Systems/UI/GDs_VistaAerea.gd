extends Control

@export_group("Datos")
@export var lblVelocidad: Label
@export var lblRotacion: Label
@export var lblFov: Label


func _process(delta: float) -> void:
	lblVelocidad.text = UTILITIES.FormatVelocidad(CAM.speed)
	lblRotacion.text = UTILITIES.FormatRotacionY(CAM.rotation.y)
	lblFov.text = UTILITIES.FormatFov(CAM.fov)
