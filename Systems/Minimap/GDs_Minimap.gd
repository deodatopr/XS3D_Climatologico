extends Node

@export var pivot_cam : Node3D
@export var map_Movement_Speed : float = 1
var movement_Vector : Vector2
var mark_Start_Position : Vector2

@onready var map_texture: TextureRect = $Minimap_Parent/Circle_Mask/Map_Texture
@onready var cam_ref: TextureRect = $Minimap_Parent/Circle_Mask/Cam_Ref
@onready var mark_test: ColorRect = $Minimap_Parent/Circle_Mask/Map_Texture/Mark_Test
@onready var minimap_parent : Control = $Minimap_Parent



func _ready() -> void:
	mark_Start_Position = mark_test.global_position
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	movement_Vector = Vector2(APPSTATE.camInputPan.x, APPSTATE.camInputPan.z)
	map_texture.position += movement_Vector * map_Movement_Speed
	
	var markDirection = Vector2(map_texture.size/2).direction_to(mark_Start_Position)
	mark_test.position = (map_texture.size/2) + (markDirection * 100)
	#print(markDirection)
	
	cam_ref.rotation_degrees = -pivot_cam.rotation_degrees.y + 180
	
#func _input(event):
	#if event.is_action_pressed("Open_Minimap"):
		#print(minimap_parent.scale)
		#var minimap_Animation : Tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		#if minimap_parent.scale.floor() > Vector2(0, 0):
			#minimap_Animation.tween_property(minimap_parent, "scale", Vector2(0, 0), 1)
		#else:
			#minimap_Animation.tween_property(minimap_parent, "scale", Vector2(1, 1), 1)
