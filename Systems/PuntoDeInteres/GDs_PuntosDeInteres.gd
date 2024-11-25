extends Node

@export_group("Refs Externas")
@export var puntosInteres : Node
@export_group("Refs Internas")
@export var camMng : GDs_Cam_Manager
@export var pfbUIPin: PackedScene
@export var canvas: CanvasLayer



var camSky: Camera3D
var camFly: Camera3D

var PDIs: Array[Node3D]
# Called when the node enters the scene tree for the first time.
func _ready():
	camSky = camMng.sky_cam
	camFly = camMng.fly_cam
	
	for child in puntosInteres.get_children():
		if child is Node3D and child.visible:
			PDIs.append(child)
	
	
	for pdi in PDIs:
		var uiPDI = pfbUIPin.instantiate() as GDs_PdI_UIPin
		canvas.add_child(uiPDI)
		uiPDI.cameraFly = camFly
		uiPDI.cameraSky = camSky
		uiPDI.pinWorldPos = pdi
		uiPDI.Initialize()
