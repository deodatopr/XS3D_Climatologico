extends Node

@export var cam_Manager : GDs_Cam_Manager
@export var map_Movement_Speed : float = 1
@export var mark_target : Node3D
@export var site_color : Color
var cam_pivot : Node3D
var cam : Node3D
var movement_Vector : Vector2
var mark_Start_Position : Vector2

@onready var map_texture: TextureRect = $Minimap_Parent/Circle_Mask/Map_Texture
@onready var cam_ref: TextureRect = $Minimap_Parent/Circle_Mask/Cam_Ref
@onready var mark_test: ColorRect = $Minimap_Parent/Circle_Mask/Mark_Test
@onready var minimap_parent : Control = $Minimap_Parent
@onready var circle_mask = $Minimap_Parent/Circle_Mask

func _ready() -> void:
	cam_pivot = cam_Manager.pivot_cam
	cam = cam_Manager.cam
	mark_Start_Position = mark_test.position
	
	mark_test.color = site_color
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	movement_Vector = Vector2(APPSTATE.camInputPan.x, APPSTATE.camInputPan.z)
	map_texture.position += movement_Vector * map_Movement_Speed
	
	var distance := Vector3(cam_pivot.global_position.x, 0, cam_pivot.global_position.z).distance_to(Vector3(mark_target.global_position.x, 0, mark_target.global_position.z))
	var markDirection := Vector3(cam_pivot.global_position.x, 0, cam_pivot.global_position.z).direction_to(Vector3(mark_target.global_position.x, 0, mark_target.global_position.z))
	var mark_x_position := clampf(mark_Start_Position.x + (-Vector2(markDirection.x, markDirection.z) * distance * 10).x, mark_Start_Position.x - circle_mask.size.x/3, mark_Start_Position.x + circle_mask.size.x/3)
	var mark_y_position := clampf(mark_Start_Position.y + (-Vector2(markDirection.x, markDirection.z) * distance * 10).y, mark_Start_Position.y - circle_mask.size.y/3, mark_Start_Position.y + circle_mask.size.y/3)
	mark_test.position = Vector2(mark_x_position, mark_y_position)#mark_Start_Position + (-Vector2(markDirection.x, markDirection.z) * distance * 10)
	#print(mark_test.position)
	
	cam_ref.rotation_degrees = -cam_pivot.rotation_degrees.y + 180
	
#func _input(event):
	#if event.is_action_pressed("Open_Minimap"):
		#print(minimap_parent.scale)
		#var minimap_Animation : Tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		#if minimap_parent.scale.floor() > Vector2(0, 0):
			#minimap_Animation.tween_property(minimap_parent, "scale", Vector2(0, 0), 1)
		#else:
			#minimap_Animation.tween_property(minimap_parent, "scale", Vector2(1, 1), 1)
