class_name GDs_Minimap extends Node

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
var wasInitialized : bool


func Initialize(_cam_Manager : GDs_Cam_Manager, _map : Texture2D) -> void:
	cam_Manager = _cam_Manager
	pivot_cam = cam_Manager.sky_pivot
	map_texture.texture = _map

	mark.self_modulate = APPSTATE.currntSitio.color
	wasInitialized = true
	
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	if wasInitialized:
		var posX : float = lerpf(0,map_texture.size.x, 1 - CAM.positionXZ_01.x) - (cam_pivot.size.x * .5)
		var posY : float = lerpf(0,map_texture.size.y, 1 - CAM.positionXZ_01.y)  - (cam_pivot.size.y *.5)
			
		cam_pivot.position = Vector2(posX,posY)
		cam_pivot.rotation_degrees = -pivot_cam.rotation_degrees.y
		lblDistance.text = str(CAM.distToSitio)
