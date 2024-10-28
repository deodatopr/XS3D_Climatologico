class_name GDs_Minimap
extends Node

@export var cam_Manager : GDs_Cam_Manager
@export var map_Movement_Speed : float = 1
@export var mark_target : Node3D
@export var estacion_color : int = 0
@export var map : Node3D
var pivot_cam : Node3D
var cam : Node3D
var movement_Vector : Vector2
var mark_Start_Position : Vector2
var cam_start_position : Vector2
var scene_bound : AABB

@onready var map_texture: TextureRect = $Minimap_Parent/Circle_Mask/Map_Texture
@onready var mark: TextureRect = $Minimap_Parent/Circle_Mask/Map_Texture/Mark
@onready var minimap_parent : Control = $Minimap_Parent
@onready var circle_mask = $Minimap_Parent/Circle_Mask
@onready var cam_pivot = $Minimap_Parent/Circle_Mask/Cam_Pivot

@onready var local_estaciones : GDs_CR_LocalEstaciones = preload("uid://3nj42mys6ryu")

var isInitialized:=false

func Initialize() -> void:
	#FIXME el movimiento del dron con la posicion del marcador del minimapa esta invertido
	pivot_cam = cam_Manager.dron_pivot
	cam = cam_Manager.dron_cam
	
	mark_Start_Position = mark.position
	cam_start_position = cam_pivot.position
	
	mark.self_modulate = local_estaciones.LocalEstaciones[estacion_color].color
	
	scene_bound = get_scene_bounds(map)
	isInitialized = true
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	if isInitialized:
		var cam_in_world = (pivot_cam.global_position + (scene_bound.size/2))/scene_bound.size
		var cam_world2D = Vector2(1 - cam_in_world.x, 1 - cam_in_world.z)
		cam_pivot.position = (cam_world2D * map_texture.size) - (map_texture.size/2) + cam_start_position
		
		cam_pivot.rotation_degrees = pivot_cam.rotation_degrees.y
	
func get_scene_bounds(root : Node) -> AABB:
	var total_aabb = AABB()
	for node in root.get_children():
		if node is MeshInstance3D:
			total_aabb = total_aabb.merge(node.get_aabb())
	return total_aabb	
