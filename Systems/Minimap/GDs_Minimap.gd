class_name GDs_Minimap extends Node

@export var VistaSky : GDs_Vista_Drone
@export var estacion_color : int = 0

@onready var map_texture: TextureRect = $Minimap_Parent/Circle_Mask/Map_Texture
@onready var mark: TextureRect = $Minimap_Parent/Circle_Mask/Map_Texture/Mark
@onready var minimap_parent : Control = $Minimap_Parent
@onready var circle_mask = $Minimap_Parent/Circle_Mask
@onready var cam_pivot : Control = $Minimap_Parent/Circle_Mask/Cam_Pivot

@onready var local_estaciones : GDs_CR_LocalEstaciones = preload("uid://3nj42mys6ryu")

var cam_Manager : GDs_Cam_Manager
var map : Node3D
var pivot_cam : Node3D
var cam : Node3D
var movement_Vector : Vector2
var mark_Start_Position : Vector2
var cam_start_position : Vector2

var isInitialized:=false

func _ready():
	Initialize()

func Initialize() -> void:
	cam_Manager = VistaSky.cam_manager
	pivot_cam = cam_Manager.sky_pivot
	cam = cam_Manager.sky_cam
	
	mark_Start_Position = mark.position
	cam_start_position = cam_pivot.position
	
	mark.self_modulate = local_estaciones.LocalEstaciones[estacion_color].color
	isInitialized = true
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	if isInitialized:
		var currX01 : float = inverse_lerp(-1,1,CAM.positionXZ_01.x)
		var posX : float = lerpf(0,map_texture.size.x, currX01) - (cam_pivot.size.x /2)
		
		var currY01 : float = inverse_lerp(-1,1,CAM.positionXZ_01.y)
		var posY : float = lerpf(0,map_texture.size.y, currY01) - (cam_pivot.size.y /2)
			
		cam_pivot.position = Vector2(posX,posY)
		cam_pivot.rotation_degrees = -pivot_cam.rotation_degrees.y
