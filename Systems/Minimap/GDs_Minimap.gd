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
@onready var mark: ColorRect = $Minimap_Parent/Circle_Mask/Map_Texture/Mark
@onready var minimap_parent : Control = $Minimap_Parent
@onready var circle_mask = $Minimap_Parent/Circle_Mask
@onready var cam_pivot = $Minimap_Parent/Circle_Mask/Cam_Pivot

@onready var local_estaciones : GDs_CR_LocalEstaciones = preload("uid://3nj42mys6ryu")

func _ready() -> void:
	pivot_cam = cam_Manager.pivot_cam
	cam = cam_Manager.cam
	mark_Start_Position = mark.position
	cam_start_position = cam_pivot.position
	
	mark.color = local_estaciones.LocalEstaciones[estacion_color].color
	
	scene_bound = get_scene_bounds(map)
	print(scene_bound.size)
	print(scene_bound.size.normalized())
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	var cam_in_world = (pivot_cam.global_position + (scene_bound.size/2))/scene_bound.size
	var cam_world2D = Vector2(1 - cam_in_world.x, 1 - cam_in_world.z)
	cam_pivot.position = (cam_world2D * map_texture.size) - (map_texture.size/2) + cam_start_position
	
	cam_pivot.rotation_degrees = -pivot_cam.rotation_degrees.y + 180
	
func get_scene_bounds(root : Node) -> AABB:
	var total_aabb = AABB()
	for node in root.get_children():
		if node is MeshInstance3D:
			total_aabb = total_aabb.merge(node.get_aabb())
	return total_aabb	
	
func _input(event):
	if event.is_action_pressed("Open_Minimap"):
		#print(minimap_parent.scale)
		var minimap_Animation : Tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		if minimap_parent.scale.floor() > Vector2(0, 0):
			minimap_Animation.tween_property(minimap_parent, "scale", Vector2(0, 0), 1)
		else:
			minimap_Animation.tween_property(minimap_parent, "scale", Vector2(1, 1), 1)
