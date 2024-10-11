@tool
extends Node

@export var label_3d : Label3D
@export var sprite_pin: Sprite3D

@export var siteName : String = "Site":
	set(value):
		siteName = value
		label_3d.text = value
		
@export var pinColor : Color = Color.WHITE:
	set(value):
		pinColor = value
		sprite_pin.modulate = pinColor
		
@export var textOffset : Vector2:
	set(value):
		textOffset = value
		label_3d.offset = value
		
