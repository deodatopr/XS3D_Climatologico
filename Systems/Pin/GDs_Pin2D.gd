@tool
extends Node

@export var label_3d : Label3D
@export var sprite_pin: Sprite3D

@export var siteName : String = "Site":
	set(value):
		siteName = value
		label_3d.text = value
		
@export var estacion_index : int = 0:
	set(value):
		estacion_index = value
		sprite_pin.modulate =  APPSTATE.currntSitio.color
		
@export var textOffset : Vector2:
	set(value):
		textOffset = value
		label_3d.offset = value
		
