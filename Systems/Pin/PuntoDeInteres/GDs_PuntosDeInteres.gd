extends Node

@export var pfbUIPin: PackedScene
@export var camFly: Camera3D
@export var camSky: Camera3D
@export_group("Refs Internas")
@export var canvas: CanvasLayer

var PDIs: Array[Node3D]
# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is Node3D and child.visible:
			PDIs.append(child)
	
	for pdi in PDIs:
		var uiPDI = pfbUIPin.instantiate() as GDs_PdI_UIPin
		canvas.add_child(uiPDI)
		uiPDI.cameraFly = camFly
		uiPDI.cameraSky = camSky
		uiPDI.pinWorldPos = pdi
		uiPDI.Initialize()
