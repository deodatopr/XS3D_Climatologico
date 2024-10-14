extends Node

@export var pivot_cam : Node3D
@export var map_Movement_Speed : float = 1
var movement_Vector : Vector2
var mark_Start_Position : Vector2

@onready var map_texture: TextureRect = $Minimap_Parent/Circle_Mask/Map_Texture
@onready var cam_ref: TextureRect = $Minimap_Parent/Circle_Mask/Cam_Ref
@onready var mark_test: ColorRect = $Minimap_Parent/Circle_Mask/Map_Texture/Mark_Test

func _ready() -> void:
	mark_Start_Position = mark_test.global_position
	
func _process(delta: float) -> void:
	movement_Vector = Vector2(APPSTATE.camInputPan.x, APPSTATE.camInputPan.z)
	map_texture.position += movement_Vector * map_Movement_Speed
	
	var markDirection = Vector2(map_texture.size/2).direction_to(mark_Start_Position)
	mark_test.position = (map_texture.size/2) + (markDirection * 100)
	print(markDirection)
	
	cam_ref.rotation_degrees = -pivot_cam.rotation_degrees.y + 180
	
