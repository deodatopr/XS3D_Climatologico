@tool
extends Node

@export var label_3d : Label3D
@export var mesh_Pin: MeshInstance3D

@export var siteName : String = "Site":
	set(value):
		siteName = value
		label_3d.text = value
		
@export var textOffset : Vector2:
	set(value):
		textOffset = value
		label_3d.offset = value
