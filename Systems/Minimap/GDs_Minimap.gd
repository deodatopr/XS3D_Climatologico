extends Node

@export var cam_Manager : GDs_Cam_Manager
@export var map_Movement_Speed : float = 1
@export var mark_target : Node3D
@export var estacion_color : int = 0
var cam_pivot : Node3D
var cam : Node3D
var movement_Vector : Vector2
var mark_Start_Position : Vector2

@onready var map_texture: TextureRect = $Minimap_Parent/Circle_Mask/Map_Texture
@onready var cam_ref: TextureRect = $Minimap_Parent/Circle_Mask/Cam_Ref
@onready var mark: ColorRect = $Minimap_Parent/Circle_Mask/Mark
@onready var minimap_parent : Control = $Minimap_Parent
@onready var circle_mask = $Minimap_Parent/Circle_Mask

@onready var local_estaciones : GDs_CR_LocalEstaciones = preload("uid://3nj42mys6ryu")

func _ready() -> void:
	cam_pivot = cam_Manager.pivot_cam
	cam = cam_Manager.cam
	mark_Start_Position = mark.position
	
	mark.color = local_estaciones.LocalEstaciones[estacion_color].color
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	movement_Vector = Vector2(APPSTATE.camInputPan.x, APPSTATE.camInputPan.z)
	map_texture.position += movement_Vector * map_Movement_Speed
	
	var distance := Vector3(cam_pivot.global_position.x, 0, cam_pivot.global_position.z).distance_to(Vector3(mark_target.global_position.x, 0, mark_target.global_position.z))
	var markDirection := Vector3(cam_pivot.global_position.x, 0, cam_pivot.global_position.z).direction_to(Vector3(mark_target.global_position.x, 0, mark_target.global_position.z))
	var mark_x_position := mark_Start_Position.x + (-Vector2(markDirection.x, markDirection.z) * distance * 10).x
	var mark_y_position := mark_Start_Position.y + (-Vector2(markDirection.x, markDirection.z) * distance * 10).y
	mark.position = Vector2(mark_x_position, mark_y_position)
	#print(markDirection)
	
	cam_ref.rotation_degrees = -cam_pivot.rotation_degrees.y + 180
	
func _input(event):
	if event.is_action_pressed("Open_Minimap"):
		#print(minimap_parent.scale)
		var minimap_Animation : Tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		if minimap_parent.scale.floor() > Vector2(0, 0):
			minimap_Animation.tween_property(minimap_parent, "scale", Vector2(0, 0), 1)
		else:
			minimap_Animation.tween_property(minimap_parent, "scale", Vector2(1, 1), 1)
