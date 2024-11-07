class_name GDs_Minimap extends Node

@export_group("SCENE REFERENCES")
@export var VistaSky : GDs_Vista_Sky

@export_group("INTERNAL REFERENCES")
@export var minimap_parent : Control
@export var circle_mask : Control
@export var map_texture: TextureRect
@export var mark: TextureRect
@export var cam_pivot : Control
@export var lblDistance : Label

var cam_Manager : GDs_Cam_Manager
var map : Node3D
var pivot_cam : Node3D
var isInitialized:=false


func Initialize(_cam_Manager : GDs_Cam_Manager) -> void:
	cam_Manager = VistaSky.cam_manager
	pivot_cam = cam_Manager.sky_pivot
	#TODO: Inyectar color dependiendo el sitio actual
	#mark.self_modulate = local_estaciones.LocalEstaciones[estacion_color].color
	isInitialized = true
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	if isInitialized:
		var posX : float = lerpf(0,map_texture.size.x, CAM.positionXZ_01.x) - (cam_pivot.size.x * .5)
		var posY : float = lerpf(0,map_texture.size.y, CAM.positionXZ_01.y)  - (cam_pivot.size.y *.5)
			
		cam_pivot.position = Vector2(posX,posY)
		cam_pivot.rotation_degrees = -pivot_cam.rotation_degrees.y
		lblDistance.text = str(CAM.distToSitio)
