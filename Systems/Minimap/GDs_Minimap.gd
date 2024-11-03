class_name GDs_Minimap extends Node

@export_group("SCENE REFERENCES")
@export var VistaSky : GDs_Vista_Drone

@export_group("INTERNAL REFERENCES")
@export var minimap_parent : Control
@export var circle_mask : Control
@export var map_texture: TextureRect
@export var mark: TextureRect
@export var cam_pivot : Control
@export var lblDistance : Label

@onready var local_estaciones : GDs_CR_LocalEstaciones = preload("uid://3nj42mys6ryu")

var cam_Manager : GDs_Cam_Manager
var map : Node3D
var pivot_cam : Node3D
var isInitialized:=false

#TODO: Conectar para que reciba el color de la estacion a la que se entró
var estacion_color : int = 1

func _ready():
	Initialize()

func Initialize() -> void:
	cam_Manager = VistaSky.cam_manager
	pivot_cam = cam_Manager.sky_pivot
	mark.self_modulate = local_estaciones.LocalEstaciones[estacion_color].color
	isInitialized = true
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	if isInitialized:
		var posX : float = lerpf(0,map_texture.size.x, CAM.positionXZ_01.x) - (cam_pivot.size.x * .5)
		
		var currY01 : float = inverse_lerp(-1,1,CAM.positionXZ_01.y)
		var posY : float = lerpf(0,map_texture.size.y, CAM.positionXZ_01.y)  - (cam_pivot.size.y *.5)
			
		cam_pivot.position = Vector2(posX,posY)
		cam_pivot.rotation_degrees = -pivot_cam.rotation_degrees.y
		lblDistance.text = str(CAM.distToSitio)
