extends Node

@export var Compass : Polygon2D
@export var Speed : float
@export var Parent : Control
@export var Pivot : Node3D
@export var MarkRef : Array[Node3D]
@export var CompassLenght : float

var Marker = preload("res://SYSTEMS/Compass/Pfb_MarkTest.tscn")


func _ready() -> void:
	SIGNALS.OnCameraRotation.connect(_CameraRotation)
	for Mark in MarkRef:
		_SetMarkerPosition(Mark)

func _CameraRotation(_roation : float):
	Compass.texture_offset.x += _roation * Speed
	
func _SetMarkerPosition(NewMark : Node3D):
	var instance : GDs_CompassMark = Marker.instantiate()
	instance._initialize(Pivot, NewMark, CompassLenght)
	Parent.add_child(instance)

	
